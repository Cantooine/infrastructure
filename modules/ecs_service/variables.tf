variable "service_name" {
  description = "The name of the service"
  type        = string
}

variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "task_definition" {
  description = "The task definition to use for the service"
  type        = string
}

variable "launch_type" {
  description = "The launch type on which to run your service"
  type        = string
  default     = "FARGATE"
}

variable "subnets" {
  description = "The subnets associated with the task or service"
  type        = list(string)
}

variable "security_groups" {}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
}

variable "load_balancers" {
  description = "List of load balancer configurations"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}
