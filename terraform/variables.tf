variable "profile" {
  default = "nginx-user"
}

variable "region" {
  default = "us-east-1"
}

variable "instance" {
  default = "t2.nano"
}

variable "instance_count" {
  default = "1"
}

variable "public_key" {
  default = "~/.ssh/github.pub"
}

variable "private_key" {
  default = "~/.ssh/github.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "amis" {
  type = "map"

  default = {
    us-east-1 = "ami-e0efab88"
    us-west-1 = "ami-b4869ff1"
    us-west-2 = "ami-431a4273"
  }
}

variable "ami" {
  default = "ami-0817d428a6fb68645"
}