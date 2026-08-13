resource "aws_lambda_function" "ai_triage" {
  function_name = "${var.project_name}-ai-triage"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 30 # a chamada pra IA pode demorar alguns segundos

  filename         = "${path.module}/../../lambda/ai-triage/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../../lambda/ai-triage/function.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = data.terraform_remote_state.observability.outputs.sns_topic_arn
    }
  }

  tags = {
    Name = "${var.project_name}-ai-triage"
  }
}

# Permite que o SNS invoque essa Lambda
resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ai_triage.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.terraform_remote_state.observability.outputs.sns_topic_arn
}

# Inscreve a Lambda no tópico SNS - toda vez que um alarme disparar, ela é chamada
resource "aws_sns_topic_subscription" "lambda_trigger" {
  topic_arn = data.terraform_remote_state.observability.outputs.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ai_triage.arn
}