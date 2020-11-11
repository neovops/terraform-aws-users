variable "all_users_group_name" {
  type        = string
  default     = "users"
  description = "Group name with all users."
}

variable "super_admin_group_name" {
  type        = string
  default     = "admins"
  description = "Group name for super admins users."
}

variable "super_admin_users" {
  type        = list(string)
  default     = []
  description = "Super admin users to create, with all privileges."
}
