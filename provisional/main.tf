provider "aws" {
  region = "us-east-1"
  alias = "us1"
}


provider "aws" {
  region = "us-east-2"
  alias = "us2"
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # Wrap the value in square brackets to form a list
  }
}









resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair in aws
resource "aws_key_pair" "aws_key" {
  key_name   = "utc-app5_key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "utc-app5_key.pem"
  content  = tls_private_key.ec2_key.private_key_pem
}



resource "aws_instance" "name" {
  provider = aws.us1  # this is to tell terraform the region u want ur instance to be created
 vpc_security_group_ids = ["sg-033e66f0034c86584"]
  key_name = aws_key_pair.aws_key.key_name
    ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  
}
                                  # it is advisable to put our provisioner under the null resource block
resource "null_resource" "n1" {   # interraform a null resource is an empty container
                                  # this is just like doing some leight thing on my server like ssh to it, pin it to see if its up an runing
  
  provisioner "local-exec" {      # local exec means run this command locally . it will run only on my lapto . will not go an run online
   command = "touch terraform.txt"
  }

  provisioner "file" {    # this help us to redirect our file to our system directory ie dev, var, tmp / file name
    source = "terraform.txt"
    destination = "/tmp/terraform.txt"
  }

  provisioner "remote-exec" {         # remote exec means run this command inside my ec2 instance
    inline = [                        #this will help us connect to the server remotely
      "touch valery" ,                #we are adding files , installing create groups on our server
      
     ]
  }
     depends_on = [aws_instance.name,local_file.ssh_key]
  
  connection {                #this will open port 22 for us to ssh in to the server       
    type = "ssh"
    port = 22
    user = "ec2-user"
    host = aws_instance.name.public_ip
    private_key = file(local_file.ssh_key.filename)
  }
}

