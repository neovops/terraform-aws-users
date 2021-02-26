[![Neovops](https://neovops.io/images/logos/neovops.svg)](https://neovops.io)

# Terraform AWS users module

Terraform module to provision aws iam users suitable for humans.

This module create a group for all users with a policy to allow self  
management common actions (password reset, etc.).

You can also create custom groups with specifics policies.

## Terraform registry

This module is available on
[terraform registry](https://registry.terraform.io/modules/neovops/users/aws/latest).

## Example

```hcl
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
  source = "neovops/users/aws"
  # You should set specific version
  # version = "x.y.z"

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

    developers = {
      users    = ["firstname3.lastname3"]
      policies = ["EC2FullAccess"]
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.14.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.14.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) |
| [aws_iam_group_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) |
| [aws_iam_group_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| all\_users\_group\_name | Group name with all users. | `string` | `"users"` | no |
| group\_policies | Policies that can be used in groups. Key is policy name, value is policy. | `map(string)` | `{}` | no |
| groups | Groups to create. Key is group name. Each policy is a string and must exists in group\_policies | <pre>map(<br>    object({<br>      users    = list(string)<br>      policies = list(string)<br>    })<br>  )</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| all\_users | All users list managed by this module |
