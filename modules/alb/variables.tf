variable "alb_name" {
  description = "The name of the load balancer"
  type        = string
}

variable "is_internal" {
  description = "Boolean to determine if the load balancer is internal"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The VPC ID where the load balancer and target groups will be created"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to attach to the load balancer"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to assign to the load balancer"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Indicates whether deletion protection is enabled on the load balancer"
  type        = bool
  default     = false
}

variable "target_group_name" {
  description = "The name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "The port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

variable "target_group_protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
}

variable "listener_port" {
  description = "The port on which the load balancer is listening"
  type        = number
}

variable "listener_protocol" {
  description = "The protocol for connections from clients to the load balancer"
  type        = string
}

variable "health_check" {
  description = "A map containing health check configuration parameters"
  type = object({
    enabled             = bool
    path                = string
    port                = string
    protocol            = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  type        = number
  default     = 300
}

variable "tg_tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "target_group_target_type" {
  description = "The target type of the target group"
  type        = string
}

variable "listener_priority" {
  type        = number
  description = "The priority for the listener rule"
}

variable "listener_conditions" {
  description = "A list of conditions for the listener rule."
  type = list(object({
    path_pattern = string
  }))
  default = []
}
