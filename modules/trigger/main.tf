data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "trigger_lambda.zip"

  source {
    content  = <<-EOF
      import boto3

      def lambda_handler(event, context):
          ec2 = boto3.client('ec2', region_name='us-west-2')
          response = ec2.start_instances(InstanceIds=['${var.ec2_instance_id}'])
      EOF
    filename = "trigger_lambda.py"
  }
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.app_name}-${var.deployment_name}-trigger"

  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler       = "trigger_lambda.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-${var.deployment_name}-trigger"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ec2_permissions" {
  statement {
    actions = [
      "ec2:StartInstances",
#      "ec2:StopInstances",
    ]

    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/${var.ec2_instance_id}"
    ]
  }
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "${var.app_name}-${var.deployment_name}-trigger"
  description = "Allows starting and stopping EC2 instances"
  policy      = data.aws_iam_policy_document.ec2_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}