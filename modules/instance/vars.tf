variable "env" {
    default = "dev"
}

# variable "aws_key_pair" {
#   default = "~/aws/aws_keys/Mumbai_keypair.pem"
# }



variable "InstanceType" {
    default = "t2.micro"
}    

variable "sg_id" {}
 
variable "pub_sbnt_id" {}
variable "private_nat_sg" {}
variable "private_sbnt_id" {}

