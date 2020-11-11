# Terraform AWS users module

[Neovops](https://neovops.io)

Terraform module to provision aws iam users suitable for humans.

This module create a group for all users with a policy to allow self  
management common actions (password reset, etc.).

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.14.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.14.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| all\_users\_group\_name | Group name with all users. | `string` | `"users"` | no |
| super\_admin\_group\_name | Group name for super admins users. | `string` | `"admins"` | no |
| super\_admin\_users | Super admin users to create, with all privileges. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| all\_users | All users list managed by this module |

