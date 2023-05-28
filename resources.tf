data "aws_ami" "fedora_coreos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["fedora-coreos-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "description"
    values = ["*stable*"]
  }

  owners = ["125523088429"] # Fedora Project
}

resource "aws_vpc" "minecraft" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

resource "aws_subnet" "minecraft" {
  vpc_id     = aws_vpc.minecraft.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

resource "aws_internet_gateway" "minecraft" {
  vpc_id = aws_vpc.minecraft.id

  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

resource "aws_route_table" "minecraft" {
  vpc_id = aws_vpc.minecraft.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft.id
  }

  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

resource "aws_route_table_association" "minecraft" {
  subnet_id      = aws_subnet.minecraft.id
  route_table_id = aws_route_table.minecraft.id
}

resource "aws_security_group" "minecraft" {
  name        = "${var.app_name} - ${var.deployment_name}"
  description = "Security group for ${var.app_name} - ${var.deployment_name}"
  vpc_id      = aws_vpc.minecraft.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowlisted_cidr_ranges
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = var.allowlisted_cidr_ranges
  }

  ingress {
    from_port = 19132
    to_port = 19132
    protocol = "udp"
    cidr_blocks = var.allowlisted_cidr_ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

resource "tls_private_key" "minecraft" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "minecraft" {
  key_name   = "${var.app_name} - ${var.deployment_name}"
  public_key = tls_private_key.minecraft.public_key_openssh
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

data "ct_config" "minecraft" {
  content = templatefile("${path.module}/files/ignition/butane.yaml.tpl", {
    format_mcserver_volume_service_contents = templatefile("${path.module}/files/systemd/format-mcserver-volume.service.tpl", {
      mcserver_data_dir = var.mcserver_data_dir
      ebs_volume_device = var.ebs_volume_device
    })

    var_opt_mcserver_mount_contents = templatefile("${path.module}/files/systemd/var-opt-mcserver.mount.tpl", {
      mcserver_data_dir = var.mcserver_data_dir
      ebs_volume_device = var.ebs_volume_device
    })

    download_papermc_plugins_service_contents = templatefile("${path.module}/files/systemd/download-papermc-plugins.service.tpl", {
      mcserver_data_dir         = var.mcserver_data_dir
      papermc_container_tag     = var.papermc_container_tag
      papermc_server_memorysize = var.papermc_server_memorysize
    })

    mcserver_service_contents = templatefile("${path.module}/files/systemd/mcserver.service.tpl", {
      mcserver_data_dir         = var.mcserver_data_dir
      papermc_container_tag     = var.papermc_container_tag
      papermc_server_memorysize = var.papermc_server_memorysize
    })

    url_encoded_zincati_config = urlencode(file("${path.module}/files/zincati/55-updates-strategy.toml"))
  })
  strict = true
}

resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.fedora_coreos.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.minecraft.id
  key_name                    = aws_key_pair.minecraft.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.minecraft.id
  ]

  user_data = data.ct_config.minecraft.rendered

  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

# Don't exit until the EC2 instances is reachable via SSH
resource "null_resource" "ssh_available" {
  depends_on = [
    aws_instance.minecraft,
    local_sensitive_file.private_key
  ]

  connection {
    host        = aws_instance.minecraft.public_ip
    type        = "ssh"
    user        = "core"
    private_key = file(pathexpand("${var.private_ssh_key_dir}/${var.app_name}-${var.deployment_name}.pem"))
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Successfully connected to ${aws_instance.minecraft.private_dns} over SSH!'"
    ]
  }
}

resource "aws_ebs_volume" "minecraft" {
  availability_zone = aws_instance.minecraft.availability_zone
  size              = var.data_volume_size
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name} Data"
    Deployment = var.deployment_name
  }
}

resource "aws_volume_attachment" "minecraft" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.minecraft.id
  instance_id = aws_instance.minecraft.id
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.minecraft.private_key_pem
  filename        = pathexpand("${var.private_ssh_key_dir}/${var.app_name}-${var.deployment_name}.pem")
  file_permission = "0600"
}