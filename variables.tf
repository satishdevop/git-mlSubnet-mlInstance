


# variable "region" {
#     default = "ap-south-1"
# }

variable "m_vpc_cidr" {
default = "10.0.0.0/16"
} 
variable "m_public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}

variable "m_private_subnet_cidr" {
    default = "10.0.10.0/24"
    }

variable "m_env" {
  default = "dev"
}

variable "m_InstanceType" {
  default = "t2.micro"
}




