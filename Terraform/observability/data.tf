provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "kaique-air-terraform-state"
    key    = "compute/terraform.tfstate"
    region = "us-east-1"
  }
}