# Creating launch Template to define instance configuration for the production ASG.
resource "aws_launch_template" "lt-prd" {
  name                        = "lt-prd"
  image_id                    = var.ami-prd
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [ var.asg-sg ]
  key_name                    = var.key_pair
  user_data                   = base64encode(templatefile("./module/stage-asg/docker-script.sh", {
    nexus-ip                  = var.nexus-ip
    newrelic-license-key      = var.nr-key
    newrelic-account-id       = var.nr-acc-id
  }))
  tags = {
    Name = "lt-prd"
  }
}

# creating autoscaling group for the production environment
resource "aws_autoscaling_group" "asg-prd" {
  name                      = var.asg-prd-name
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = [var.prod-tg]
  launch_template {
    id = aws_launch_template.lt-prd.id
  }
  tag {
    key                 = "Name"
    value               = "ASG"
    propagate_at_launch = true
  }
}

# creating production autoscaling policy for dynamic scaling based on CPU utilization.
resource "aws_autoscaling_policy" "asp-prd" {
  autoscaling_group_name = aws_autoscaling_group.asg-prd.name
  name                   = "prd-asg-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}