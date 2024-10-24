#Nexus server
resource "aws_instance" "nexus" {
  ami                         = var.redhat_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.nexus-sg]
  subnet_id                   = var.pub-subnet-id
  key_name                    = var.key_pair
  user_data                   = local.nexus_user_data
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = var.nexus-name
  }
}

#creating nexus elb
resource "aws_elb" "elb-nexus" {
  name            = "elb-nexus"
  security_groups = [var.nexus-sg]
  subnets         = var.nexus-subnets

  listener {
    instance_port      = 8081
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl-cert
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