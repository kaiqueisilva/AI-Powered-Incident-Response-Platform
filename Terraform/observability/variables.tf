variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "air"
}

variable "alert_email" {
  description = "Email para receber alertas do CloudWatch"
  type        = string
  sensitive   = true
}

variable "cpu_threshold" {
  type    = number
  default = 80
}