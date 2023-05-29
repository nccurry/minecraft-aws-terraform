data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = "dlm-lifecycle-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    App        = var.app_name
    Deployment = var.deployment_name
  }
}

data "aws_iam_policy_document" "dlm_lifecycle" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*::snapshot/*"]
  }
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "${lower(var.app_name)}-${lower(var.deployment_name)}-dlm-lifecycle-policy"
  role   = aws_iam_role.dlm_lifecycle_role.id
  policy = data.aws_iam_policy_document.dlm_lifecycle.json
}

resource "aws_dlm_lifecycle_policy" "dlm_lifecycle_policy" {
  description        = "${var.app_name} - ${var.deployment_name} DLM lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "The last 3 daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 3
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      Snapshot = "true"
    }
  }

  tags = {
    Name       = "${var.app_name} - ${var.deployment_name}"
    App        = var.app_name
    Deployment = var.deployment_name
  }
}