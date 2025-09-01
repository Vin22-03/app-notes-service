resource "aws_cloudwatch_log_group" "notes_logs" {
  name              = "/ecs/notes-app-v3"
  retention_in_days = 7
}
