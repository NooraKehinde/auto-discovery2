# stage target group 
resource "aws_lb_target_group" "stage-tg" {
  name        = "stage-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc
  health_check {
    interval = 30
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 5
  }
}

## Application load balancer
resource "aws_lb" "stage-alb" {
  name               = "stage-alb"
  load_balancer_type = "application"
  internal = false
  security_groups    = var.stage-sg
  subnets            = var.stage-subnet
  enable_deletion_protection = false
  tags = {
    Name: "stage-alb"
  }
}

#stage http listener
resource "aws_lb_listener" "stage-http" {
  load_balancer_arn = aws_lb.stage-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-tg.arn
  }
}

# Listener for the front-end load balancer
resource "aws_lb_listener" "stage-https" {
  load_balancer_arn = aws_lb.stage-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl-cert

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-tg.arn
  }
}
