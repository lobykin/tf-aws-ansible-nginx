variable "s3_bucket_name" {
  default = "nginx-dynamo-bucket-888"
}
variable "dynamo_db_table_name" {
  default = "nginx-locks-2"
}
variable "iam_user_name" {
  default = "nginx-user"
}

variable "profile" {
  default = "nginx-user"
}

variable "log_role" {
  default = "docker-nginx-logs"
}

variable "region" {
  default = "us-east-1"
}

variable "instance" {
  default = "t2.micro"
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

variable "influxdb_user_password" {}

variable "aws_access_key_id" {}

variable "aws_secret_access_key" {}

variable "influxdb_ip" {}