provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "arkdev-tfstate"
    key    = "hosting/terraform.tfstate"
    region = "us-east-1"
  }
}
