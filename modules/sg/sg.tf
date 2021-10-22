resource "aws_security_group" "web" {
  name        = "vpc_web-${var.env}"
  description = "Allow incoming HTTP connections."
  #vpc_id      = aws_vpc.vpc.id
  vpc_id      = var.vpcId


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]

  }



  tags = {
    Name = "WebServerSG-new-${var.env}"
    environment = var.env
  }
}
resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
 # vpc_id = aws_vpc.vpc.id
 vpc_id = var.vpcId

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ALB-SG-${var.env}"
    environment = var.env
  }

}


resource "aws_security_group" "private_nat" {
  name        = "vpc_db-${var.env}"
  description = "Allow incoming database connections."
  #vpc_id      = aws_vpc.vpc.id
  vpc_id = var.vpcId



  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]

  }



  tags = {
    Name = "private_ser_sg-${var.env}"
    environment = var.env
  }
}
output "sg_Id" {
    value = "${aws_security_group.web.id}"
}

output "sg_nat_Id" {
    value = "${aws_security_group.private_nat.id}"
}
output "sG_id" {
    value = "${aws_security_group.alb_sg.id}"
}