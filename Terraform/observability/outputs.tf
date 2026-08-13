output "alb_arn_suffix" {
  value = data.terraform_remote_state.compute.outputs.alb_arn_suffix
}

output "target_group_arn_suffix" {
  value = data.terraform_remote_state.compute.outputs.target_group_arn_suffix
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}