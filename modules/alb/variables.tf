variable "alb_name" {
  type        = string
  description = "The name of the ALB"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the ALB is created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to attach to the ALB"
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to attach to the ALB"
}

variable "target_group_name" {
  type        = string
  description = "The name of the target group"
}

variable "health_check_path" {
  type        = string
  description = "The health check path"
  default     = "/"
}

variable "listener_port" {
  type        = number
  description = "The port on which the load balancer is listening"
  default     = 80
}
