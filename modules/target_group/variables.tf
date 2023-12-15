variable "name" {
  description = "The name of the target group"
  type        = string
}

variable "port" {
  description = "The port on which targets receive traffic"
  type        = number
}

variable "protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "vpc_id" {
  description = "The identifier of the VPC in which to create the target group"
  type        = string
}

variable "health_check" {
  description = "A map containing health check settings"
  type        = map(any)
  default = {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  type        = number
  default     = 300
}

variable "tags" {
  description = "A map of tags to add to the target group"
  type        = map(string)
  default     = {}
}
