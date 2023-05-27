provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "minecraft" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Minecraft - ${var.deployment_name}"
    Deployment = var.deployment_name
  }
}

resource "aws_subnet" "minecraft" {
  vpc_id     = aws_vpc.minecraft.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Minecraft - ${var.deployment_name}"
    Deployment =  var.deployment_name
  }
}

resource "aws_internet_gateway" "minecraft" {
  vpc_id = aws_vpc.minecraft.id

  tags = {
    Name = "example_igw"
  }
}

resource "aws_route_table" "minecraft" {
  vpc_id = aws_vpc.minecraft.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft.id
  }

  tags = {
    Name = "example_route_table"
  }
}

resource "aws_route_table_association" "minecraft" {
  subnet_id      = aws_subnet.minecraft.id
  route_table_id = aws_route_table.minecraft.id
}

resource "aws_security_group" "minecraft" {
  name        = "Minecraft - ${var.deployment_name}"
  description = "Security group for Minecraft servers"
  vpc_id      = aws_vpc.minecraft.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowlisted_cidr_ranges
  }

  ingress {
    from_port   = 19132
    to_port     = 19132
    protocol    = "udp"
    cidr_blocks = var.allowlisted_cidr_ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "Minecraft - ${var.deployment_name}"
    Deployment =  var.deployment_name
  }
}

resource "tls_private_key" "minecraft" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "minecraft" {
  key_name   = "Minecraft - ${var.deployment_name}"
  public_key = tls_private_key.minecraft.public_key_openssh
  tags = {
    Name = "Minecraft - ${var.deployment_name}"
    Deployment =  var.deployment_name
  }
}

resource "aws_instance" "minecraft" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.minecraft.id
  key_name      = aws_key_pair.minecraft.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.minecraft.id
  ]

  user_data = <<-EOF
              #!/bin/bash

              # Update packages
              apt-get update
              apt-get upgrade -y
              apt-get install wget unzip

              # Download Minecraft
              SERVER_VERSION="${var.minecraft_version}"
              DOWNLOAD_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-$SERVER_VERSION.zip"
              ZIP_FILE="bedrock-server-$SERVER_VERSION.zip"
              wget $DOWNLOAD_URL -O $ZIP_FILE
              unzip $ZIP_FILE
              rm $ZIP_FILE
              EOF

  tags = {
    Name = "Minecraft - ${var.deployment_name}"
    Deployment =  var.deployment_name
  }
}

resource "aws_ebs_volume" "minecraft" {
  availability_zone = aws_instance.minecraft.availability_zone
  size              = var.volume_size
  tags = {
    Name = "Minecraft - ${var.deployment_name}"
    Deployment =  var.deployment_name
  }
}

resource "aws_volume_attachment" "minecraft" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.minecraft.id
  instance_id = aws_instance.minecraft.id
}

resource "local_file" "private_key" {
  content = tls_private_key.minecraft.private_key_pem
  filename          = pathexpand("~/.ssh/Minecraft-${var.deployment_name}.pem")
  file_permission   = "0600"
}

output "public_ip_address" {
  value = aws_instance.minecraft.public_ip
}