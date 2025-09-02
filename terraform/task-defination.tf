resource "aws_ecs_task_definition" "notes_app_task" {
  family                   = "notes-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "notes-app"
      image     = "921483785411.dkr.ecr.us-east-1.amazonaws.com/vin-notes-app:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/notes-app"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
 # ✅ Force ECS to replace task definition each time
  lifecycle {
    create_before_destroy = true
  }
}
