# Creating launch Template to define instance configuration for the stage ASG.
resource "aws_launch_template" "lt-stg" {
  name                        = "lt-stg"
  image_id                    = var.ami-stg
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [ var.asg-sg ]
  key_name                    = var.key_pair
  user_data                   = base64encode(templatefile("./module/stage-asg/docker-script.sh", {
    nexus-ip                  = var.nexus-ip
    newrelic-license-key      = var.nr-key
    newrelic-account-id       = var.nr-acc-id
  }))
  tags = {
    Name = "lt-stg"
  }
}

# creating autoscaling group for the stage environment
resource "aws_autoscaling_group" "asg-stg" {
  name                      = var.asg-stg-name
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = [var.stage-tg]
  launch_template {
    id = aws_launch_template.lt-stg.id
  }
  tag {
    key                 = "Name"
    value               = "ASG"
    propagate_at_launch = true
  }
}

# creating stage autoscaling policy for dynamic scaling based on CPU utilization.
resource "aws_autoscaling_policy" "asg-policy-stg" {
  autoscaling_group_name = aws_autoscaling_group.asg-stg.name
  name                   = "stg-asg-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}