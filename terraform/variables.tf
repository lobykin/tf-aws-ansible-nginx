variable "s3_bucket_name" {
  default = "nginx-dynamo-bucket-888"
}
variable "dynamo_db_table_name" {
  default = "nginx-locks"
}
variable "iam_user_name" {
  default = "nginx-user"
}

variable "state_key" {
  default = "terraform.tfstate"
}

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
  default = "~/.ssh/ec2_key_pair.pub"
}

variable "private_key" {
  default = "~/.ssh/ec2_key_pair.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "ami" {
  default = "ami-0817d428a6fb68645"
}