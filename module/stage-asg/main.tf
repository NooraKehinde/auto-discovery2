# Creating launch Template to define instance configuration for the stage ASG.
resource "aws_launch_template" "lt-stg1" {
  name                        = var.stage-lt
  image_id                    = var.ami-stg
  instance_type               = "t2.medium"
  key_name                    = var.key_pair
  vpc_security_group_ids      = [aws_security_group.stage_asg_sg.id]
  user_data                   = base64encode(templatefile("./module/stage-asg/docker-script.sh", {
    nexus-ip                  = var.nexus-ip
    newrelic-license-key      = var.nr-key
    newrelic-account-id       = var.nr-acc-id
  }))
  tags = {
    Name = var.stage-lt 
  }
}

# creating autoscaling group for the stage environment
resource "aws_autoscaling_group" "asg-stg" {
  name                      = var.stage-asg-name
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = [aws_lb_target_group.stage-tg.arn]
  launch_template {
    id = aws_launch_template.lt-stg1.id
  }
  tag {
    key                 = "Name"
    value               = var.stage-asg-name
    propagate_at_launch = true
  }
}

# creating stage autoscaling policy for dynamic scaling based on CPU utilization.
resource "aws_autoscaling_policy" "asp-stg" {
  autoscaling_group_name = aws_autoscaling_group.asg-stg.name
  name                   = var.stage-asg-policy
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

# stage target group 
resource "aws_lb_target_group" "stage-tg" {
  name        = var.stage-tg
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc
  health_check {
    interval  = 30
    timeout   = 5
    healthy_threshold = 3
    unhealthy_threshold = 5
  }
}

# Application load balancer
resource "aws_lb" "stage-alb" {
  name               = var.stage-alb
  load_balancer_type = "application"
  internal           = false
  subnets            = var.stage-subnet
  security_groups    = [aws_security_group.stage_asg_sg.id]
  enable_deletion_protection = false
  tags = {
    Name = var.stage-alb
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

# Security Group for ASG
resource "aws_security_group" "stage_asg_sg" {
  name        = "${var.name}-stage-asg-sg"
  description = "Allow inbound and outbound traffic for ASG"
  vpc_id      = var.vpc

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "${var.name}-stage-asg-sg"
  }
}
