data "aws_iam_policy_document" "full_access" {
  statement {
    sid       = "AllowFullAccess"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2_full_access" {
  statement {
    sid       = "EC2FullAccess"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
}

module "users" {
  source = "../../"

  group_policies = {
    EC2FullAccess = data.aws_iam_policy_document.ec2_full_access.json
    FullAccess    = data.aws_iam_policy_document.full_access.json
  }

  groups = {
    admins = {
      users = [
        "firstname1.lastname1",
        "firstname2.lastname2",
      ]
      policies = ["FullAccess"]
    }

    developpers = {
      users    = ["firstname3.lastname3"]
      policies = ["EC2FullAccess"]
    }
  }
}
