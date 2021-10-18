


variable "region" {
    default = "ap-south-1"
}
variable "vpc_cidr" {
default = "10.0.0.0/16"
} 
variable "aws_key_pair" {
  default = "~/aws/aws_keys/Mumbai_keypair.pem"
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}

variable "private_subnet_cidr" {
    default = "10.0.10.0/24"
    }

variable "InstanceType" {
    default = "t2.micro"
}    

variable "env" {
    default = "dev"
}

