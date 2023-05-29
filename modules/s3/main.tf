terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.1, < 6.0.0"
    }
  }
}

resource "aws_s3_bucket" "resource_packs" {
  bucket = lower("${var.app_name}-${var.deployment_name}-resource-packs")
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name} Data"
    App = var.app_name
    Deployment = var.deployment_name
  }
}

data "aws_iam_policy_document" "resource_packs" {
  statement {
    actions   = ["s3:GetObject"]
    effect = "Allow"
    resources = ["${aws_s3_bucket.resource_packs.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values = var.allowlisted_cidr_ranges
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.resource_packs.id
  policy = data.aws_iam_policy_document.resource_packs.json
}

resource "aws_s3_object" "john_smith_resource_pack" {
  key    = "John Smith Legacy Bedrock 1.19.83.zip"
  bucket = aws_s3_bucket.resource_packs.id
  source = "${path.module}/files/resource-packs/John Smith Legacy Bedrock 1.19.83.zip"
  force_destroy = true
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name} Data"
    App = var.app_name
    Deployment = var.deployment_name
  }
}