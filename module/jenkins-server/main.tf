resource "aws_instance" "Jenkins" {
  ami                         = var.redhat_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.jenkins_sg.id] 
  subnet_id                   = var.subnet_id
  key_name                    = var.pub_key_name
  user_data                   = local.jenkins-userdata

  tags = {
    Name = var.jenkins_name
  }
}


# Creating Jenkins ELB
resource "aws_elb" "elb-jenkins" {
  name            = "elb-jenkins"
  security_groups = [aws_security_group.jenkins_sg.id]
  subnets         = var.jenkins_subnets

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl_cert 
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:8080"
    interval            = 30
  }

   instances                  = [aws_instance.Jenkins.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "jenkins-elb"
  }
}

# Security Group for Nexus
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.name}-jenkins-sg"
  description = "Allow inbound and outbound traffic for Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "${var.name}-jenkins-sg"
  }
}

# Creating A Jenkins Record
resource "aws_route53_record" "jenkins_record" {
  zone_id = data.aws_route53_zone.pet_zone.zone_id
  name    = var.jenkins_domain
  type    = "A"
  alias {
    name                   = aws_elb.elb-jenkins.dns_name
    zone_id                = aws_elb.elb-jenkins.zone_id
    evaluate_target_health = true
  }
}

# Creating Route53 Hosted Zone
data "aws_route53_zone" "pet_zone" {
  name         = var.domain
  private_zone = false
}