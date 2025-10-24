terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "hello-world-ml-tf-state-942497601151"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hello-world-ml-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.default_tags, {
      Environment = var.environment
    })
  }
}