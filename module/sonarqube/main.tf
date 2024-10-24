# EC2 Instance for SonarQube
resource "aws_instance" "sonarqube_instance" {
  ami           = var.ubuntu_ami # Update with a valid Ubuntu AMI ID for your region
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.sonarqube-sg]
  associate_public_ip_address = true
  key_name = var.pub_key_name # Update with your key pair name

  user_data = local.sonarqube-userdata

  tags = {
    Name = var.sonar_name
  }
}

#creating nexus elb
resource "aws_elb" "elb-sonar" {
  name            = "elb-sonar"
  security_groups = [var.sonarqube-sg]
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