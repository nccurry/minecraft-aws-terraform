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
  description = "The AWS Region to deploy infrastructure into"
  type        = string
  default     = "us-east-2"
}

variable "allowlisted_cidr_ranges" {
  description = "The CIDR ranges that can communicate with the Minecraft server"
  type        = list(string)
}

# https://aws.amazon.com/ec2/pricing/on-demand/
# https://aws.amazon.com/ec2/instance-types/
variable "ec2_instance_type" {
  description = "The EC2 instance type of the server"
  type        = string
  default     = "c6a.large"
}

variable "ebs_data_volume_size" {
  description = "The size of the EBS volume for the Minecraft data"
  type        = number
  default     = 50
}

# This is different for different EC2 instance types (e.g. /dev/xvdb, /dev/nvme1n1, etc)
variable "data_volume_device_path" {
  description = "The device path of the EBS volume for storing server data"
  type        = string
  default     = "/dev/nvme1n1"
}

variable "papermc_server_memorysize" {
  description = "The value for the papermc container MEMORYSIZE environment variable"
  type        = string
  default     = "2G"
}

variable "private_ssh_key_dir" {
  description = "Path to download local private SSH key"
  type        = string
  default     = "~/.ssh"
}

variable "download_private_ssh_key" {
  description = "Whether to download the ssh private key locally"
  type        = bool
  default     = true
}