provider "aws" {
  region     = var.region
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_launch_template" "lt" {
    name_prefix   = "${var.cluster_name}-lt"
    image_id      = var.ami
    instance_type = var.instance_type
    key_name      = aws_key_pair.key.key_name

    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "${var.cluster_name}-instance"
      }
    }
}
resource "aws_key_pair" "key" {
  key_name   = "${var.cluster_name}-key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_autoscaling_group" "asg" {
    name_prefix               = "${var.cluster_name}-asg"
    vpc_zone_identifier       = data.aws_subnets.default.ids
    min_size                  = var.min_size
    max_size                  = var.max_size
    health_check_grace_period = 200
    health_check_type         = "EC2"
    force_delete              = true
    launch_template {
      id      = aws_launch_template.lt.id
      version = "$Latest"
    }

    tag {
        key                 = "Name"
        value               = "${var.cluster_name}-asg"
        propagate_at_launch = true

    }

}

# Create a CloudWatch alarm for CPU Utilization above 60%
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name                = "${var.cluster_name}-high-cpu"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 60
  alarm_actions             = [aws_autoscaling_policy.scaling_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

# Autoscaling Step Scaling Policy (for scaling out/in based on CPU)
resource "aws_autoscaling_policy" "scaling-policy" {
  name                    = "${var.cluster_name}-cpu_policy-out"
  policy_type             = "StepScaling"
  autoscaling_group_name  = aws_autoscaling_group.asg.name
  adjustment_type         = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = 1  # Scale out by 1 instance
    metric_interval_lower_bound = 60  # When CPU goes above 60%
  }

  step_adjustment {
    scaling_adjustment          = -1  # Scale in by 1 instance
    metric_interval_upper_bound = 60  # When CPU goes below 60%
  }

  cooldown = 30
}

