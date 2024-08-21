provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # Wrap the value in square brackets to form a list
  }
}

#how to delete a specific resource with affecting others
# on ur prompt shell run , run terraform state list  then u can choose the resource u which to delete and run,
#  terraform destroy --target aws_instance.dev




resource "aws_instance" "server" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true  #this argument can only be use when u want to destroy a resouce an recreate it
  }       # bulance value are anything that has true or false

#lifecycle {  # how do we prevent resource from being delete by third party even by mistake, we use life cycle argument.
 # prevent_destroy = false  # to undo it change true to false
#}
}

# other lifecycle can be ignore change, triger by etc

resource "aws_iam_user" "user1" {
  name = "peter"
}

