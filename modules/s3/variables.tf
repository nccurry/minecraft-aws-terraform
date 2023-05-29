variable "app_name" {
  description = "The name of this application"
  type        = string
}

variable "deployment_name" {
  description = "The unique name of this deployment"
  type        = string
}

variable "allowlisted_cidr_ranges" {
  description = "The CIDR ranges that can communicate with the Minecraft server"
  type        = list(string)
}