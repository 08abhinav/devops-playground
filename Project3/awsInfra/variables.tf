variable "instance_type"{
  type        = string
  default     = "t2.micro"
  description = "specifying the ram, cpu"
}

variable "keyPair"{
  type        = string
  default     = "shell-practice"
  description = "key pair for ssh to remote server"
}
