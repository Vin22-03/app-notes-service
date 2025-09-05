# codedeploy.tf
resource "aws_codedeploy_app" "ecs_app" {
  name = "vin-notes-codedeploy"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs_dg" {
  app_name              = aws_codedeploy_app.ecs_app.name
  deployment_group_name = "vin-notes-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                          = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  ecs_service {
    cluster_name = var.ecs_cluster
    service_name = aws_ecs_service.notes_service_v4.name
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.notes_tg_v4.name
      }
      target_group {
        name = aws_lb_target_group.notes_tg_v4_green.name
      }

      prod_traffic_route {
        listener_arns = [aws_lb_listener.notes_listener_v4.arn]
      }
    }
  }
}
