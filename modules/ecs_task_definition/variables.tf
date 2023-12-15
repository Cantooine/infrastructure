variable "family" {
  description = "The family of the task definition"
  type        = string
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task"
  type        = string
  default     = "awsvpc"
}

variable "task_role_arn" {
  description = "The ARN of the IAM role that allows your Amazon ECS container task to make calls to other AWS services"
  type        = string
}

variable "execution_role_arn" {
  description = "The execution role ARN to use"
  type        = string
}

variable "cpu" {
  description = "The amount of CPU used to allocate for the task"
  type        = string
}

variable "memory" {
  description = "The amount of memory used to allocate for the task"
  type        = string
}

variable "container_definitions" {
  description = "A list of container definitions in JSON format"
  type        = any
}
