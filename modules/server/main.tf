terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.1, < 6.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4, < 5.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1, < 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

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

resource "aws_security_group" "security_group" {
  name        = "${var.app_name} - ${var.deployment_name}"
  description = "Security group for ${var.app_name} - ${var.deployment_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowlisted_cidr_blocks
  }

  # Plan
  ingress {
    from_port   = 8804
    to_port     = 8804
    protocol    = "tcp"
    cidr_blocks = var.allowlisted_cidr_blocks
  }

  # Bluemap
  ingress {
    from_port   = 8100
    to_port     = 8100
    protocol    = "tcp"
    cidr_blocks = var.allowlisted_cidr_blocks
  }

  # Java Edition
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = var.allowlisted_cidr_blocks
  }

  # Bedrock Edition
  ingress {
    from_port   = 19132
    to_port     = 19132
    protocol    = "udp"
    cidr_blocks = var.allowlisted_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    App        = var.app_name
    Deployment = var.deployment_name
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.app_name} - ${var.deployment_name}"
  public_key = tls_private_key.private_key.public_key_openssh
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    App        = var.app_name
    Deployment = var.deployment_name
  }
}

resource "aws_secretsmanager_secret" "public_key" {
  name_prefix                    = "${var.app_name}-${var.deployment_name}-public-key"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "public_key" {
  secret_id     = aws_secretsmanager_secret.public_key.id
  secret_string = tls_private_key.private_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "private_key" {
  name_prefix                    = "${var.app_name}-${var.deployment_name}-private-key"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "private_key" {
  secret_id     = aws_secretsmanager_secret.public_key.id
  secret_string = tls_private_key.private_key.private_key_pem
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    App        = var.app_name
    Deployment = var.deployment_name
  }
}

resource "aws_eip_association" "eip_association" {
  instance_id   = aws_instance.instance.id
  allocation_id = aws_eip.eip.id
}

resource "null_resource" "user_data_trigger" {
  triggers = {
    ec2_user_data = var.ec2_user_data
  }
}

resource "aws_instance" "instance" {
  lifecycle {
    replace_triggered_by = [null_resource.user_data_trigger]
  }
  ami               = data.aws_ami.fedora_coreos.id
  instance_type     = var.ec2_instance_type
  subnet_id         = var.subnet_id
  key_name          = aws_key_pair.key_pair.key_name
  availability_zone = var.availability_zone

  vpc_security_group_ids = [
    aws_security_group.security_group.id
  ]

  user_data = var.ec2_user_data

  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    App        = var.app_name
    Deployment = var.deployment_name
  }
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.availability_zone
  size              = var.ebs_data_volume_size
  type              = "gp3"
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name} Data"
    App        = var.app_name
    Deployment = var.deployment_name
    Snapshot   = "true"
  }
}

resource "aws_volume_attachment" "volume_attachment" {
  device_name = "/dev/xvdf" # Not sure what's going on this this name
  volume_id   = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.instance.id
}