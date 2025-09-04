resource "aws_ecs_service" "notes_service_v4" {
  name            = "notes-service-v4"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.notes_app_task_v4.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.notes_tg_v4.arn
    container_name   = "notes-app-v4"
    container_port   = 8000
  }

  force_new_deployment = true

#  depends_on = [aws_lb_listener.notes_listener_v4]
}
