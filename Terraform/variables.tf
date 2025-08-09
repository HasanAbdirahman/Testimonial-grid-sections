variable "subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "subnet_cidrs" {
  description = "CIDR blocks for each public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}