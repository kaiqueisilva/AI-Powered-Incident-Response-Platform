variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado em tags e nomes de recursos"
  type        = string
  default     = "air" # ai-incident-response
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  description = "Quantidade de subnets públicas (uma por AZ)"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Quantidade de subnets privadas (uma por AZ)"
  type        = number
  default     = 2
}