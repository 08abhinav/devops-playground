variable "cidr_block" {
  description = "cidr block for vpc"
  default = "10.0.0.0/16"
}

variable "subnet_cidr"{
  description = "cidr block for subnet1 inside myvpc"
  default = "10.0.0.0/24"
}

variable "az"{
  description = "availability zone for subnet1"
  default = "us-east-1a"
}
