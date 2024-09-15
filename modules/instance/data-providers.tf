data "aws_availability_zones" "available" {
  state = "available"
}

# data "aws_ami" "centos_8" {
#   most_recent = true
#   #owners      = ["amazon"]
#   owners= ["125523088429"]
#   filter {
#     name   = "name"
#     values = ["CentOS 8.4.2105 x86_64"]
#   }
# }