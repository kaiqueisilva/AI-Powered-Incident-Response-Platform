resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-app"
  retention_in_days = 7 # não guarda pra sempre, evita custo crescente

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}