provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "kaique-air-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "kaique-air-terraform-state"
    key    = "ecr/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}