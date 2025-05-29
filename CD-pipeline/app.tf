resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "my-container"
      image = "${data.terraform_remote_state.ci_pipeline.outputs.repository_uri}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.example_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 2
  launch_type     = "EC2"

  load_balancer {
    elb_name        = aws_elb.my-elb.name
    container_name   = "my-container"
    container_port   = 80
  }

  depends_on = [aws_ecs_cluster_capacity_providers.ecs_cp]
}
