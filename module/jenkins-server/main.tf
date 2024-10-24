# Creating Jenkins server
resource "aws_instance" "Jenkins" {
  ami                         = var.redhat_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.jenkins-sg]
  subnet_id                   = var.pub_subnet
  key_name                    = var.keypair
  user_data                   = local.jenkins-userdata
  tags = {
    Name = var.jenkins-name
  }
}

#creating nexus elb
resource "aws_elb" "elb-jenkins" {
  name            = "elb-jenkins"
  security_groups = [var.jenkins-sg]
  subnets         = var.jenkins-subnets

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl-cert
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:8080"
    interval            = 30
  }

  instances                   = [aws_instance.Jenkins.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "jenkins-elb"
  }
}