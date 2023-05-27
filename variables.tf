variable "deployment_name" {
  description = "The unique name of this deployment"
  type = string
  default = "Main"
}

variable "allowlisted_cidr_ranges" {
  description = "The CIDR ranges that can communicate with the Minecraft server"
  type = list(string)
}

variable "instance_type" {
  description = "The EC2 instance type of the server"
  type = string
  default = "t2.small"
}

variable "minecraft_version" {
  description = "The server version to download"
  type = string
  default = "1.19.83.01"
}

variable "volume_size" {
  description = "The size of the EBS volume for the Minecraft data"
  type = number
  default = 10
}