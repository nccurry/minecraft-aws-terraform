variable "data_volume_device_path" {
  description = "The device path of the EBS volume for storing server data"
  type        = string
}

# https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server
variable "papermc_container_image" {
  description = "The container image to use for the papermc container"
  type        = string
  default     = "docker.io/marctv/minecraft-papermc-server"
}

# https://hub.docker.com/r/marctv/minecraft-papermc-server/tags
variable "papermc_container_tag" {
  description = "The container tag to use for the papermc container"
  type        = string
  default     = "1.19"
}

variable "papermc_server_memory_size" {
  description = "The value for the papermc container MEMORYSIZE environment variable"
  type        = string
}

variable "mcserver_data_dir" {
  description = "The directory to store PaperMC server data"
  type        = string
  default     = "/var/opt/mcserver"
}