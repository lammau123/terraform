variable "aws-region" {
  type = string
  description = "AWS region"
}

variable "aws-from-port" {
  type = number
}

variable "aws-to-port" {
  type = number
}

variable "aws-ssh-to-port" {
  type = number
}

variable "aws-ssh-to-port" {
  type = number
}

variable "aws-public-key" {
  type = string
  description = "SSH public key"
}

variable "aws-ec2-instance" {
  type = string
}

variable "aws-ec2-instance-type" {
  type = string
}
