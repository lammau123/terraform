#Aws cloud provider
provider "aws" {
  version = "~> 3.0"
  region = var.aws-region
}

data "aws_availability_zones" all {
  state = "available"
}

resource "aws_security_group" "helloworld-sg" {
	name = "helloworld-sg"
	ingress {
		from_port = var.aws-from-port
		to_port = var.aws-to-port
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_launch_configuration" "helloworld-launch-config" {
  name_prefix   = "helloworld-"
  image_id      = var.aws-ec2-instance
  instance_type = var.aws-ec2-instance-type
  security_groups = ["${aws_security_group.helloworld-sg.id}"]
  key_name = aws_key_pair.deployer.id
  user_data = file("./init.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "helloworld-autoscaling-g" {
  name                 = "${aws_launch_configuration.helloworld-launch-config.name}-sg"
  launch_configuration = aws_launch_configuration.helloworld-launch-config.name
  load_balancers = ["${aws_elb.helloworld_elb.name}"]
  health_check_type = "ELB"
  min_size             = 2
  max_size             = 4
  availability_zones = data.aws_availability_zones.all.names
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "helloworld"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "elb" {
  name = "elb-security-group"
  ingress {
    from_port = 80
    to_port = 80
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
resource "aws_elb" "helloworld_elb" {
  name = "helloworld-elb"
  availability_zones = data.aws_availability_zones.all.names
  security_groups = ["${aws_security_group.elb.id}"]
  listener {
    lb_port = var.aws_lb_port
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}

output "elb_dns_name" {
  value = aws_elb.helloworld_elb.dns_name
}

#Declare public ssh key. public_key value is get from the ubuntu_key.pub
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.aws-public-key
}
