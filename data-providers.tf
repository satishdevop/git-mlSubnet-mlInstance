# data "aws_availability_zones" "available" {
#   state = "available"
# }
# /*data "aws_subnet_ids" "public" {
# vpc_id = aws_vpc.vpc.id
# filter {
#     name   = "tag:Name"
#     values = ["public-subnet"]
#   }
#   depends_on = [aws_subnet.public_subnet]
# }*/
# data "aws_instances" "bluein" {

#   filter {
#     name   = "tag:Name"
#     values = ["app_server-${var.env}"]
#   }
#   depends_on = [aws_instance.blue]
# }
# data "aws_ami" "centos_8" {
#   most_recent = true
#   #owners      = ["amazon"]
#   owners= ["125523088429"]
#   filter {
#     name   = "name"
#     values = ["CentOS 8.4.2105 x86_64"]
#   }
# }