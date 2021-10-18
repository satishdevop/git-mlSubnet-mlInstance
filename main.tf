

# locals {
#   subnet_ids = toset([
#     aws_subnet.public_subnet[0].id,
#     aws_subnet.public_subnet[1].id
#   ])
# }


provider "aws" {
  region = var.region
}


resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr //"10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = "sat-vpc"
    environment = var.env
  }
}
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
    environment = var.env
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id,0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name = "nat"
    environment = var.env

  }
}

resource "aws_subnet" "public_subnet" {
  count = "${length(data.aws_availability_zones.available.names)-1}"
  vpc_id = aws_vpc.vpc.id

  #cidr_block              = "10.0.1.0/24"
  #cidr_block = "10.0.${10+count.index}.0/24"
  cidr_block = var.public_subnet_cidr_blocks[count.index]
 # availability_zone       = "ap-south-1a"
 availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
    environment = var.env

  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = var.private_subnet_cidr //"10.0.10.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet"
    environment = var.env

  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-route-table"
    environment = var.env

  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-route-table"
    environment = var.env

  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {

  count = "${length(data.aws_availability_zones.available.names)-1}"
  subnet_id      = element(aws_subnet.public_subnet.*.id,count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {

  subnet_id      = element(aws_subnet.private_subnet.*.id, 0)
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "web" {
  name        = "vpc_web"
  description = "Allow incoming HTTP connections."
  vpc_id      = aws_vpc.vpc.id


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
    Name = "WebServerSG-new"
    environment = var.env
  }
}
resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = aws_vpc.vpc.id

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
    Name = "ALB-SG"
    environment = var.env
  }

}
////////////////////////////

resource "aws_lb" "appl" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet.*.id

  //enable_deletion_protection = true  
}
resource "aws_lb_listener" "appl" {
  load_balancer_arn = aws_lb.appl.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_lb_target_group" "blue" {
  name     = "blue-tg-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
    path = "/test.txt"
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  count            = length(aws_instance.blue)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = data.aws_instances.bluein.ids[count.index]
  port             = 80
}

////////////////////////////


resource "aws_instance" "blue" {
  #count             = 3
  count = "${length(data.aws_availability_zones.available.names)-1}"
  ami = data.aws_ami.aws_linux_2_latest.id
  key_name                    = "Mumbai_keypair"
  instance_type               = var.InstanceType
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  associate_public_ip_address = true
 // for_each = local.subnet_ids
 // subnet_id     = each.key

#   for_each      = data.aws_subnet_ids.public.ids
#    subnet_id     = each.value
  subnet_id = aws_subnet.public_subnet[count.index].id

 /* user_data     = <<-EOF
  #!/bin/bash
 sudo yum update -y
 sudo yum install -y httpd
 systemctl start httpd
 systemctl enable httpd
 sudo echo 'hi there from user data' > /var/www/html/test.txt
echo "done"
                  EOF  */
 /* connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo service httpd start",
      "echo welcome to skps27 - virtual server is at ${self.public_dns} | sudo tee /var/www/html/test.txt"
    ]
  }*/

  tags = {
     Name = "app_server"
    owner = "satish_devops"
    os    = "amazon_linux"
    environment = var.env
  }
  depends_on = [aws_subnet.public_subnet]
  
}




resource "aws_security_group" "private_nat" {
  name        = "vpc_db"
  description = "Allow incoming database connections."
  vpc_id      = aws_vpc.vpc.id



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
    Name = "private_ser_sg"
    environment = var.env
  }
}

resource "aws_instance" "private_ssh1" {
  #ami               = "ami-04db49c0fb2215364"

  ami = data.aws_ami.aws_linux_2_latest.id
  #ami = "ami-0c1a7f89451184c8b"
  availability_zone = "ap-south-1b"
  # key_name = aws_key_pair.my_key.key_name
  key_name               = "Mumbai_keypair"
  instance_type          = var.InstanceType
  vpc_security_group_ids = ["${aws_security_group.private_nat.id}"]
  subnet_id              = aws_subnet.private_subnet.id


  tags = {
    Name = "private-instance"
    environment = var.env
  }
}

