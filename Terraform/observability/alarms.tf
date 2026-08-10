
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = {
    Name = "${var.project_name}-alerts"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU do ECS Service acima de 80% por 2 minutos seguidos"

  dimensions = {
    ClusterName = "${var.project_name}-cluster"
    ServiceName = "${var.project_name}-service"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.project_name}-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Existe pelo menos 1 target unhealthy no ALB"

  dimensions = {
    TargetGroup  = data.terraform_remote_state.compute.outputs.target_group_arn_suffix
    LoadBalancer = data.terraform_remote_state.compute.outputs.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_5xx" {
  alarm_name          = "${var.project_name}-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Mais de 5 erros 5xx em 1 minuto"

  dimensions = {
    LoadBalancer = data.terraform_remote_state.compute.outputs.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}