# EC2 Instance for SonarQube
resource "aws_instance" "sonarqube_instance" {
  ami                         = var.ubuntu_ami 
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  security_groups             = [aws_security_group.sonarqube_sg.id] 
  associate_public_ip_address = true
  key_name                    = var.pub_key_name 
  user_data                   = local.sonarqube-userdata

  tags = {
    Name = var.sonar_name
  }
}

# ELB for SonarQube
resource "aws_elb" "elb-sonar" {
  name            = "elb-sonar"
  security_groups = [aws_security_group.sonarqube_sg.id] 
  subnets         = var.sonar-subnets

  listener {
    instance_port      = 9000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl-cert
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:9000"
    interval            = 30
  }

  instances                   = [aws_instance.sonarqube_instance.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "sonarqube-elb"
  }
}

# Security Group for SonarQube
resource "aws_security_group" "sonarqube_sg" {
  name        = "${var.name}-sonarqube-sg"
  description = "Allow outbound traffic"
  vpc_id      = var.vpc-id
  
  ingress {
    from_port   = 9000
    to_port     = 9000
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
    Name = "${var.name}-sonarqube-sg"
  }
}

#creating A sonar record
resource "aws_route53_record" "sonar-record" {
  zone_id = data.aws_route53_zone.pet-zone.zone_id
  name    = var.sonar-domain
  type    = "A"
  alias {
    name                   = aws_elb.elb-sonar.dns_name
    zone_id                = aws_elb.elb-sonar.zone_id
    evaluate_target_health = true
  }
}

#creating route53 hosted zone
data "aws_route53_zone" "pet-zone" {
  name         = var.domain
  private_zone = false
}