# Nexus server
resource "aws_instance" "nexus" {
  ami                         = var.redhat_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nexus_sg.id] 
  key_name                    = var.pub_key_name
  user_data                   = local.nexus_user_data
  subnet_id                   = var.subnet_id

  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = var.nexus_name
  }
}

# Creating Nexus ELB
resource "aws_elb" "elb-nexus" {
  name            = "elb-nexus"
  security_groups = [aws_security_group.nexus_sg.id]
  subnets         = var.nexus_subnets

  listener {
    instance_port      = 8081
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl_cert
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:8081"
    interval            = 30
  }

  instances                   = [aws_instance.nexus.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "nexus-elb"
  }
}

# Security Group for Nexus
resource "aws_security_group" "nexus_sg" {
  name        = "${var.name}-nexus-sg"
  description = "Allow inbound and outbound traffic for Nexus"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "${var.name}-nexus-sg"
  }
}

# Creating A Nexus Record
resource "aws_route53_record" "nexus_record" {
  zone_id = data.aws_route53_zone.pet_zone.zone_id
  name    = var.nexus_domain
  type    = "A"
  alias {
    name                   = aws_elb.elb-nexus.dns_name
    zone_id                = aws_elb.elb-nexus.zone_id
    evaluate_target_health = true
  }
}

# Creating Route53 Hosted Zone
data "aws_route53_zone" "pet_zone" {
  name         = var.domain
  private_zone = false
}