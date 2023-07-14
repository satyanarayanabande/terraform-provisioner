resource "aws_key_pair" "provisioner" {
  key_name   = "provisioner"
  public_key = file("C:\\Users\\TOSHIBA\\provisioner.pub")
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow all ports"
  vpc_id      = "vpc-08dd73f4e02812fd8" #default vpcb id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "your-wish" {
   ami = "ami-057752b3f1d6c4d6c"
   #from instance type map instance will be selected based on the current workspace
   instance_type = "t3.medium"
   key_name = aws_key_pair.provisioner.key_name
   security_groups = [aws_security_group.allow_tls.name]
   user_data = "${file("scripts/docker.sh")}"
   # where you are running terraform command
   provisioner "local-exec" {
     command = "echo the server's ip address is ${self.public_ip} > public-ip.txt "
   }
}

#resource "aws_instance" "remote" {
#  ami = "ami-057752b3f1d6c4d6c"
#   #from instance type map instance will be selected based on the current workspace
#   instance_type = "t3.micro"
#   key_name = aws_key_pair.provisioner.key_name
#   security_groups = [aws_security_group.allow_tls.name]

#  connection {
#    type = "ssh"
#    user = "ec2-user"
#    private_key = file("C:\\Users\\TOSHIBA\\provisioner.pem")
#    host = self.public_ip
#  }


#  provisioner "remote-exec" {
#      inline = [
#        "touch /tmp/remote.txt",
#       "echo 'this file is created by rwmote provisioner' > /tmp/remote.txt "
#     ]
# }

#provisioner "remote-exec" {
#    script = "scripts/docker.sh"
# }

#  provisioner "remote-exec" {
#    inline = [
#      "id",
#      "sudo yum install nginx -y",
#      "sudo systemctl start nginx"
#    ]
# }



  