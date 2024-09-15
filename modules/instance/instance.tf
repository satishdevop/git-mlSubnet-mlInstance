resource "aws_instance" "blue" {
  count = "${length(data.aws_availability_zones.available.names)-1}"
  ami = "ami-0e53db6fd757e38c7"
  key_name                    = "Mumbai-keypair"
  instance_type               = var.InstanceType
 vpc_security_group_ids      = ["${var.sg_id}"]
  associate_public_ip_address = true

 subnet_id = var.pub_sbnt_id[count.index].id

user_data = <<-EOF
#!/bin/bash
sudo yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Fetch the public IP from the instance metadata
#INSTANCE_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Write HTML to test.html
cat <<EOM > /var/www/html/test.html
<html>
  <head>
    <title>EC2 Instance hosted application</title>
  </head>
  <body>
    <h1>Welcome!</h1>
    <p>Hi there from user data.</p>
    <p>Your EC2 instance number is: <strong>${count.index}</strong></p>
  </body>
</html>
EOM

echo "done"
EOF


  tags = {
     Name = "app_server-${var.env}"
    owner = "satish_devops"
    #os    = "amazon_linux"
    environment = var.env
  }
  #depends_on = [aws_subnet.public_subnet]
  
}


output "aws_inst_cnt" {
    value = ["${aws_instance.blue}"]
}

