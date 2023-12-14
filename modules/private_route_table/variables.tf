variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "nat_gateways" {
  description = "Map of NAT Gateway IDs keyed by availability zone."
  type        = map(string)
}

variable "subnets" {
  description = "Map of subnet IDs keyed by availability zone."
  type        = map(string)
}

variable "vpc_name" {
  type = string
}
