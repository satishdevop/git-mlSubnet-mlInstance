
region = "ap-south-1"
vpc_cidr = "10.2.0.0/16"
public_subnet_cidr_blocks = [
    "10.2.1.0/24",
    "10.2.2.0/24",
    "10.2.3.0/24",
    "10.2.4.0/24",
  ]
private_subnet_cidr = "10.2.10.0/24"
InstanceType = "t2.micro"
  env = "dev"
