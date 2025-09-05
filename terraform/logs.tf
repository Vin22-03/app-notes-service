resource "aws_cloudwatch_log_group" "notes_logs_v4" {
  name              = "/ecs/notes-app-v4"
  retention_in_days = 7
}
