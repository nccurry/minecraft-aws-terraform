variable "app_name" {
  description = "The name of this application"
  type        = string
}

variable "deployment_name" {
  description = "The unique name of this deployment"
  type        = string
}

variable "aws_region" {
  description = "The AWS Region to deploy infrastructure into"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR range of the VPC"
  type        = string
  default     = "10.0.0.0/26"
}

variable "subnet_cidr_block" {
  description = "The CIDR range of the subnet"
  type        = string
  default     = "10.0.0.0/28"
}
