terraform {
  backend "s3" {
    bucket         = "kaique-air-terraform-state"
    key            = "ai-triage/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}