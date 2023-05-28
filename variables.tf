variable "app_name" {
  description = "The name of this application"
  type        = string
  default     = "Minecraft"
}

variable "deployment_name" {
  description = "The unique name of this deployment"
  type        = string
  default     = "Main"
}

variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-2"
}

variable "allowlisted_cidr_ranges" {
  description = "The CIDR ranges that can communicate with the Minecraft server"
  type        = list(string)
}

# https://aws.amazon.com/ec2/pricing/on-demand/
# https://aws.amazon.com/ec2/instance-types/
variable "instance_type" {
  description = "The EC2 instance type of the server"
  type        = string
  default     = "r5a.large"
}

# https://hub.docker.com/r/marctv/minecraft-papermc-server/tags
# https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server
variable "papermc_container_tag" {
  description = "The container tag to use for the papermc container"
  type        = string
  default     = "1.19"
}

variable "papermc_server_memorysize" {
  description = "The value for the papermc container MEMORYSIZE environment variable"
  type        = string
  default     = "14G"
}

variable "data_volume_size" {
  description = "The size of the EBS volume for the Minecraft data"
  type        = number
  default     = 50
}

variable "private_ssh_key_dir" {
  description = "Path to download local private SSH key"
  type        = string
  default     = "~/.ssh"
}

variable "ebs_volume_device" {
  description = "The device path of the additional EBS volume"
  type        = string
  default     = "/dev/nvme1n1"
}

variable "mcserver_data_dir" {
  description = "The directory to store PaperMC server data"
  type        = string
  default     = "/var/opt/mcserver"
}