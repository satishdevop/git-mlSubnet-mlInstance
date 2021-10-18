data "aws_availability_zones" "available" {
  state = "available"
}
/*data "aws_subnet_ids" "public" {
vpc_id = aws_vpc.vpc.id
filter {
    name   = "tag:Name"
    values = ["public-subnet"]
  }
  depends_on = [aws_subnet.public_subnet]
}*/
data "aws_instances" "bluein" {

  filter {
    name   = "tag:Name"
    values = ["app_server"]
  }
  depends_on = [aws_instance.blue]
}
data "aws_ami" "aws_linux_2_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}