resource "aws_instance" "blue" {
  #count             = 3
  count = "${length(data.aws_availability_zones.available.names)-1}"
 # ami = data.aws_ami.aws_linux_2_latest.id
  ami = data.aws_ami.centos_8.id
  key_name                    = "Mumbai_keypair"
  instance_type               = var.InstanceType
 # vpc_security_group_ids      = ["${aws_security_group.web.id}"]
 vpc_security_group_ids      = ["${var.sg_id}"]
  associate_public_ip_address = true
 // for_each = local.subnet_ids
 // subnet_id     = each.key

#   for_each      = data.aws_subnet_ids.public.ids
#    subnet_id     = each.value
 # subnet_id = aws_subnet.public_subnet[count.index].id
 subnet_id = var.pub_sbnt_id[count.index].id

 /* user_data     = <<-EOF
  #!/bin/bash
 sudo yum update -y
 sudo yum install -y httpd
 systemctl start httpd
 systemctl enable httpd
 sudo echo 'hi there from user data' > /var/www/html/test.txt
echo "done"
                  EOF  */
  /*connection {
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
     Name = "app_server-${var.env}"
    owner = "satish_devops"
    #os    = "amazon_linux"
    environment = var.env
  }
  #depends_on = [aws_subnet.public_subnet]
  
}





resource "aws_instance" "private_ssh1" {
  #ami               = "ami-04db49c0fb2215364"

  ami = data.aws_ami.centos_8.id
  #ami = "ami-0c1a7f89451184c8b"
  availability_zone = "ap-south-1b"
  # key_name = aws_key_pair.my_key.key_name
  key_name               = "Mumbai_keypair"
  instance_type          = var.InstanceType
#   vpc_security_group_ids = ["${aws_security_group.private_nat.id}"]
#   subnet_id              = aws_subnet.private_subnet.id
vpc_security_group_ids = ["${var.private_nat_sg}"]
subnet_id              = var.private_sbnt_id

  tags = {
    Name = "private-instance-${var.env}"
    environment = var.env
  }
}
output "aws_inst_cnt" {
    value = ["${aws_instance.blue}"]
}

