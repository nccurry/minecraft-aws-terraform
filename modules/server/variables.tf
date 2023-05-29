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

variable "vpc_id" {
  description = "The ID of the AWS VPC in which to place the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the AWS subnet in which to place the EC2 instance"
}

variable "availability_zone" {
  description = "The availability zone in which to place the EC2 instance"
}

variable "allowlisted_cidr_blocks" {
  description = "The CIDR ranges that can communicate with the infrastructure"
  type        = list(string)
}

# https://aws.amazon.com/ec2/pricing/on-demand/
# https://aws.amazon.com/ec2/instance-types/
variable "ec2_instance_type" {
  description = "The EC2 instance type of the server"
  type        = string
}

variable "ec2_user_data" {
  description = "The UserData to pass to the EC2 instance"
  type        = string
}

variable "data_volume_device_path" {
  description = "The device path of the EBS volume for storing server data"
  type        = string
}

variable "ebs_data_volume_size" {
  description = "The size of the EBS volume for the Minecraft data"
  type        = number
}
