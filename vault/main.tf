provider "aws" {
  region = "eu-west-3"
}
terraform {
  backend "s3" {
    bucket         = "auto-discovery-s3"
    dynamodb_table = "discovery-db"
    key            = "vault/terraform.tfstate"
    encrypt        = true
    region         = "eu-west-3"
  }
}
locals {
  name = "auto-discovery"
}

resource "aws_instance" "vault_server" {
  ami                         = var.ubuntu
  subnet_id                   = "subnet-038125d7efe2cd0e0"
  instance_type               = "t2.medium"
  iam_instance_profile        = aws_iam_instance_profile.vault_profile.id
  key_name                    = aws_key_pair.public_key.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.vault-sg.id]
  user_data = templatefile("./vault_script.sh", {
    var1 = "eu-west-3"
    var2 = aws_kms_key.vault_kms.id
  })
  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "rm -f ./root_token.txt"
  # }
  tags = {
    Name = var.vault_server_name
  }
}

#create aws KMS
resource "aws_kms_key" "vault_kms" {
  description             = "KMS key"
  deletion_window_in_days = 10
  tags = {
    Name = var.vault_kms_key
  }
}

# Vault SG
resource "aws_security_group" "vault-sg" {
  name        = "vault-sg"
  description = "Vault Security Group"


  # Inbound Rules
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "vault port"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.vault_sg
  }
}

# dynamic keypair resource
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "vault-private-key"
  file_permission = "600"
}

resource "aws_key_pair" "public_key" {
  key_name   = "vault-public-key"
  public_key = tls_private_key.keypair.public_key_openssh
}

#creating route53 hosted zone
data "aws_route53_zone" "pet-zone" {
  name         = var.domain
  private_zone = false
}

#creating A vault record
resource "aws_route53_record" "vault-record" {
  zone_id = data.aws_route53_zone.pet-zone.zone_id
  name    = var.vault-domain
  type    = "A"
  alias {
    name                   = aws_elb.elb-vault.dns_name
    zone_id                = aws_elb.elb-vault.zone_id
    evaluate_target_health = true
  }
}

#creating ssl certificate
resource "aws_acm_certificate" "ssl-cert" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
#creating validation record
resource "aws_route53_record" "validate-record" {
  for_each = {
    for dvo in aws_acm_certificate.ssl-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.pet-zone.zone_id
}
resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn         = aws_acm_certificate.ssl-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validate-record : record.fqdn]
}

#creating nexus elb
resource "aws_elb" "elb-vault" {
  name            = "elb-vault"
  security_groups = [aws_security_group.vault-sg.id]
  subnets         = ["subnet-038125d7efe2cd0e0", "subnet-0bc8d6b9cc82b0333"]

  listener {
    instance_port      = 8200
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate.ssl-cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:8200"
    interval            = 30
  }

  instances                   = [aws_instance.vault_server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "vault-elb"
  }
}