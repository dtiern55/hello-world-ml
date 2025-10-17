variable "replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 2
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "hello-world-ml"
}