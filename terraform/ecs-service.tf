resource "aws_ecs_service" "notes_service_v4" {
  name            = "notes-service-v4"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.notes_app_task_v4.arn
  launch_type     = "FARGATE"
  desired_count   = 1
 
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets = [
  "subnet-0c9e45bd7228d8e23",
  "subnet-0cd730e7a5a240b8d"
    ]
    security_groups = ["sg-0cedc02bb50dd61e8"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.notes_tg_v4.arn
    container_name   = "notes-app-v4"
    container_port   = 8000
  }

    depends_on = [aws_lb_listener.notes_listener_v4]
}
