variable "all_users_group_name" {
  type        = string
  default     = "users"
  description = "Group name with all users."
}

variable "group_policies" {
  type        = map(string)
  default     = {}
  description = "Policies that can be used in groups. Key is policy name, value is policy."
}

variable "groups" {
  type = map(
    object({
      users    = list(string)
      policies = list(string)
    })
  )
  default     = {}
  description = "Groups to create. Key is group name. Each policy is a string and must exists in group_policies"
}
