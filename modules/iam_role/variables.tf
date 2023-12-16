variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "The policy that grants an entity permission to assume the role"
  type        = string
}

variable "policy_arns" {
  description = "List of ARN of the policies to attach to the role"
  type        = list(string)
}
