#Aws cloud provider
provider "aws" {
  version = "~> 3.0"
  region = var.aws-region
}
#open port 8080 for the inbound rule. 
#So request from outside can route to the server
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = var.aws-from-port
    to_port = var.aws-to-port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = var.aws-ssh-to-port
    to_port = var.aws-ssh-to-port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Declare public ssh key. public_key value is get from the ubuntu_key.pub
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.aws-public-key
}

#Create a ubuntu (ami = "ami-40d28157")
#and configuration for the server (instance_type = "t2.micro")
#these value can be checked on AWS
resource "aws_instance" "helloworld" {
  ami           = var.aws-ec2-instance
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  instance_type = var.aws-ec2-instance-type
  key_name = aws_key_pair.deployer.id
  tags = {
    Name = "terraform helloworld"
  }
  #init script is executed when the server starts.
  user_data = file("./init.sh")
}