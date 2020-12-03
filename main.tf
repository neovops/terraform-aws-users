/**
 * [![Neovops](https://neovops.io/images/logos/neovops.svg)](https://neovops.io)
 *
 * # Terraform AWS users module
 *
 * Terraform module to provision aws iam users suitable for humans.
 *
 * This module create a group for all users with a policy to allow self
 * management common actions (password reset, etc.).
 *
 * ## Example
 *
 * ```hcl
 * data "aws_iam_policy_document" "full_access" {
 *   statement {
 *     sid       = "AllowFullAccess"
 *     effect    = "Allow"
 *     actions   = ["*"]
 *     resources = ["*"]
 *   }
 * }
 *
 * data "aws_iam_policy_document" "ec2_full_access" {
 *   statement {
 *     sid       = "EC2FullAccess"
 *     effect    = "Allow"
 *     actions   = ["ec2:*"]
 *     resources = ["*"]
 *   }
 * }
 *
 * module "users" {
 *   source = "neovops/users/aws"
 *   # You should set specific version
 *   # version = "x.y.z"
 *
 *   group_policies = {
 *     EC2FullAccess = data.aws_iam_policy_document.ec2_full_access.json
 *     FullAccess    = data.aws_iam_policy_document.full_access.json
 *   }
 *
 *   groups = {
 *     admins = {
 *       users = [
 *         "firstname1.lastname1",
 *         "firstname2.lastname2",
 *       ]
 *       policies = ["FullAccess"]
 *     }
 *
 *     developpers = {
 *       users    = ["firstname3.lastname3"]
 *       policies = ["EC2FullAccess"]
 *     }
 *   }
 * }
 * ```
 */

locals {
  all_users = toset(flatten(
    [for group in var.groups : group.users]
  ))

  group_policies_flat = flatten([
    for group_name, group in var.groups : [
      for policy in group.policies : {
        group  = group_name
        policy = policy
      }
    ]
  ])
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

## Groups

resource "aws_iam_group" "groups" {
  for_each = var.groups

  name = each.key
}

resource "aws_iam_group_policy" "group_policies" {
  for_each = {
    for group_policy in local.group_policies_flat :
    "${group_policy.group}.${group_policy.policy}" => group_policy
  }

  name   = each.value.policy
  group  = aws_iam_group.groups[each.value.group].id
  policy = var.group_policies[each.value.policy]
}

resource "aws_iam_group_membership" "groups" {
  for_each = var.groups

  name  = "${each.key}-membership"
  users = [for name in each.value.users : aws_iam_user.user[name].name]
  group = aws_iam_group.groups[each.key].name
}
