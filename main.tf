terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0, < 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1, < 4.0.0"
    }
  }
}

module "network" {
  source = "./modules/network"

  app_name        = var.app_name
  deployment_name = var.deployment_name
  aws_region      = var.aws_region
}

module "ignition" {
  source = "./modules/ignition"

  data_volume_device_path    = var.data_volume_device_path
  papermc_server_memory_size = var.papermc_server_memorysize
}

module "server" {
  source = "./modules/server"

  app_name                = var.app_name
  deployment_name         = var.deployment_name
  aws_region              = var.aws_region
  vpc_id                  = module.network.vpc_id
  subnet_id               = module.network.subnet_id
  availability_zone       = module.network.subnet_availability_zone
  allowlisted_cidr_blocks = var.allowlisted_cidr_ranges
  ec2_instance_type       = var.ec2_instance_type
  data_volume_device_path = var.data_volume_device_path
  ebs_data_volume_size    = var.ebs_data_volume_size
  ec2_user_data           = module.ignition.ignition_json
}

resource "local_sensitive_file" "private_key" {
  count           = var.download_private_ssh_key ? 1 : 0
  content         = module.server.private_key
  filename        = pathexpand("${var.private_ssh_key_dir}/${var.app_name}-${var.deployment_name}.pem")
  file_permission = "0600"
}

# Don't exit until the EC2 instances is reachable via SSH
resource "null_resource" "ssh_available" {
  count = var.download_private_ssh_key ? 1 : 0
  depends_on = [
    module.server,
    local_sensitive_file.private_key
  ]

  connection {
    host        = module.server.public_ip_address
    type        = "ssh"
    user        = "core"
    private_key = file(pathexpand("${var.private_ssh_key_dir}/${var.app_name}-${var.deployment_name}.pem"))
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Successfully connected to ${module.server.public_ip_address} over SSH!'"
    ]
  }
}
