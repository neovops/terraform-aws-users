/**
 * # aws-users module
 *
 * Terraform module to provision aws iam users suitable for humans.
 *
 * This module create a group for all users with a policy to allow self
 * management common actions (password reset, etc.).
 */

locals {
  all_users = toset(concat(var.root_users))
}

resource "aws_iam_user" "user" {
  for_each = toset(local.all_users)

  name = each.value
  path = "/"

  force_destroy = true
}


resource "aws_iam_group" "all_users" {
  name = var.all_users_group_name
}

resource "aws_iam_group_membership" "all_users" {
  name  = "${var.all_users_group_name}-membership"
  users = [for name in local.all_users : aws_iam_user.user[name].name]
  group = aws_iam_group.all_users.name
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "iam_self_management" {
  statement {
    sid = "AllowSelfManagement"

    effect = "Allow"

    actions = [
      "iam:GetAccountSummary",
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GenerateCredentialReport",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:Get*",
      "iam:List*",
      "iam:ResyncMFADevice",
      "iam:UpdateAccessKey",
      "iam:UpdateLoginProfile",
      "iam:UpdateUser",
      "iam:UploadSigningCertificate",
      "iam:UploadSSHPublicKey",
    ]

    # Allow for both users with "path" and without it
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*/&{aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/&{aws:username}",
    ]
  }
}

resource "aws_iam_group_policy" "all_users_self_management" {
  name   = "SelfManagement"
  group  = aws_iam_group.all_users.id
  policy = data.aws_iam_policy_document.iam_self_management.json
}
