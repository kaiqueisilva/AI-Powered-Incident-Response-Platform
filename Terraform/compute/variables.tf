variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "air"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "container_port" {
  description = "Porta que a app escuta dentro do container"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "CPU da task Fargate (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memória da task Fargate em MB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Quantas instâncias da app rodando simultaneamente"
  type        = number
  default     = 1
}

variable "image_tag" {
  description = "Tag da imagem no ECR a ser deployada"
  type        = string
  default     = "v2"
}