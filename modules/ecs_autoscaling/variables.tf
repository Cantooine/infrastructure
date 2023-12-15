variable "service_arn" {
  description = "The ARN of the ECS service to apply the autoscaling."
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster where the service is deployed."
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of tasks to run."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks to run."
  type        = number
  default     = 3
}

variable "scale_up_cooldown" {
  description = "Cooldown period in seconds before allowing further scale up operations."
  type        = number
  default     = 300
}

variable "scale_down_cooldown" {
  description = "Cooldown period in seconds before allowing further scale down operations."
  type        = number
  default     = 300
}

variable "target_utilization" {
  description = "The target value for the metric. Auto Scaling adjusts the number of tasks to keep the metric at this value."
  type        = number
  default     = 70
}
