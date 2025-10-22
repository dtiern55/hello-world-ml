terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Empty backend - will be configured at runtime
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = merge(var.default_tags, {
      Environment = var.environment
    })
  }
}