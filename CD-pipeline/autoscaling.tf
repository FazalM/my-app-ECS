# ECS Cluster
resource "aws_ecs_cluster" "example_cluster" {
  name = "example-ecs-cluster"
}

# Launch Template for EC2 instances
resource "aws_launch_template" "example_launch_template" {
  name_prefix   = "example-launch-template-"
  image_id      = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykeypair.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_instance_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.example_cluster.name} >> /etc/ecs/ecs.config
EOF
  )

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [data.terraform_remote_state.ci_pipeline.outputs.myinstance_sg_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ec2 instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group using the Launch Template
resource "aws_autoscaling_group" "example_autoscaling" {
  name                      = "example-autoscaling"
  vpc_zone_identifier       = data.terraform_remote_state.ci_pipeline.outputs.private_subnet_ids
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.my-elb.name]
  force_delete              = true

  launch_template {
    id      = aws_launch_template.example_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ec2 instance"
    propagate_at_launch = true
  }
}

# ECS Capacity Provider linked to the ASG
resource "aws_ecs_capacity_provider" "asg_capacity_provider" {
  name = "my-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example_autoscaling.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 90
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 5
    }

    managed_termination_protection = "DISABLED"
  }
}

# Attach the Capacity Provider to the ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "ecs_cp" {
  cluster_name = aws_ecs_cluster.example_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.asg_capacity_provider.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.asg_capacity_provider.name
    weight            = 1
    base              = 1
  }
}
