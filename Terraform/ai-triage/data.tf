provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "observability" {
  backend = "s3"
  config = {
    bucket = "kaique-air-terraform-state"
    key    = "observability/terraform.tfstate"
    region = "us-east-1"
  }
}