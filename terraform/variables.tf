locals {
  environment = replace(var.environment, "_", "-")
}

variable "environment" {
  description = "Environment name we are building"
  default     = "aws_multi_region_aurora"
}

variable "my_name" {
  description = "My name"
  default     = "Todd Bernson"
}

variable "tags" {
  description = "Default tags for this environment"
  default     = {}
}