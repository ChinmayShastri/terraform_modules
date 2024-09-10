provider "aws" {
  region     = var.region
}

resource "aws_launch_template" "lt" {
    name_prefix   = "${var.cluster_name}-lt"
    image_id      = lookup(var.ami, var.region)
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

resource "aws_autoscaling_policy" "scaling-policy" {
    name = "${var.cluster_name}-cpu_policy-out"
    policy_type = "TargetTrackingScaling"
    autoscaling_group_name = aws_autoscaling_group.asg.name

    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
        target_value = 60
    }
  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_lower_bound = 1.0
    metric_interval_upper_bound = 2.0
  }

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 2.0
    metric_interval_upper_bound = 3.0
  }
}
