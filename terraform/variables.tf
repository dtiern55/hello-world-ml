variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_node_count" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 3
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project   = "hello-world-ml"
    ManagedBy = "Terraform"
  }
}