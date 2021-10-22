
region = "ap-south-1"
vpc_cidr = "10.1.0.0/16"
public_subnet_cidr_blocks = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24",
    "10.1.4.0/24",
  ]
private_subnet_cidr = "10.1.10.0/24"
InstanceType = "t2.micro"
  env = "prod"
