resource "aws_cloudwatch_log_group" "notes_logs" {
  name              = "/ecs/notes-app"
  retention_in_days = 7
}
