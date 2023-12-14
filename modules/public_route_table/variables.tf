variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
}

variable "routes" {
  type = list(map(string))
}

variable "subnet_ids" {
  type = map(string)
}
