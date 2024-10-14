terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.54.0"    # Aws provider version , not terraform version
    }
  }

  backend "s3" {
    bucket = "charan-state-dev"
    key    = "catalogue"
    region = "us-east-1"
    dynamodb_table = "charan-locking-dev"
  }
}

provider "aws" {
  region = "us-east-1"
}