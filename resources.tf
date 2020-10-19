// Creating Bucket to store the Terraform Configuration
resource "aws_s3_bucket" "state_bucket" {
  bucket = var.s3_bucket_name

// Best practice to add encryption the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

// Prevents Terraform from destroying or replacing this object
  lifecycle {
    prevent_destroy = true
  }

// Keeping versions history
  versioning {
    enabled = true
  }

  tags = {
    Terraform = "true"
  }
}

// Build a DynamoDB to use for terraform state locking
resource "aws_dynamodb_table" "tf_lock_state" {
  name = var.dynamo_db_table_name

// Pay per request is cheaper for low-i/o applications, like our TF lock state
  billing_mode = "PAY_PER_REQUEST"

// Hash key is required, and must be an attribute
  hash_key = "LockID"

// Attribute LockID is required for TF to use this table for lock state
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = var.dynamo_db_table_name
    BuiltBy = "Terraform"
  }
}
// Building role for CloudWatch pair for AWS Instance
resource "aws_iam_role" "ec2_log_role" {
  name               = "ec2-log-role"
  assume_role_policy = <<EOF
{
 "Version": "2020-10-19",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "ec2_log_policy" {
  name        = "ec2-log-policy"
  description = "Allowing write logs"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:*",
                "logs:*",
                "sns:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }],
  })
}

resource "aws_iam_policy_attachment" "ec2_log_policy_attachment" {
  name       = "ec2-log-policy-attachment"
  roles      = aws_iam_role.ec2_log_role.name
  policy_arn = aws_iam_policy.ec2_log_policy.arn
}

// Building profile
resource "aws_iam_instance_profile" "ec2_log_profile" {
  name  = "ec2-log-profile"                         
  role = aws_iam_role.ec2_log_role.name
}


// Building key pair for AWS Instance
resource "aws_key_pair" "key_pair_pem" {
  key_name   = "ec2_key_pair"
  public_key = file(var.public_key)
}
// Building  Instance
resource "aws_instance" "nginx-instance" {
  count = var.instance_count
  ami           = var.ami
  instance_type = var.instance
  key_name      = aws_key_pair.key_pair_pem.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_log_profile.name
  vpc_security_group_ids = [
    aws_security_group.nginx-web.id,
    aws_security_group.nginx-ssh.id,
    aws_security_group.nginx-egress-tls.id,
    aws_security_group.nginx-icmp.id,
	  aws_security_group.nginx-web-server.id
  ]

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 60
    encrypted             = true
    delete_on_termination = true
  }

  connection {
    type = "ssh"
    host = self.public_ip
    private_key = file(var.private_key)
    user        = var.ansible_user
  }

  provisioner "file" {
    content = templatefile("${path.module}/playbooks/export.tpl", {
        aws_access_key_id = var.aws_access_key_id
        aws_secret_access_key = var.aws_secret_access_key
    })
    destination = "/tmp/export.sh"
  } 

  provisioner "file" {
    content = templatefile("${path.module}/playbooks/docker_telegraf.tpl", {
        influxdb_url = var.influxdb_url
        influxdb_user_password = var.influxdb_user_password
    })
    destination = "/tmp/telegraf.conf"
  }  

  provisioner "remote-exec" {
    inline = [
      "echo '${var.aws_access_key_id}' >> /tmp/test.file",
      "sudo apt-get -qq install python3 -y",
      "sudo /bin/bash /tmp/export.sh"
      ]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 600;
	    >nginx-instance.ini;
	    echo "[nginx-instance]" | tee -a nginx-instance.ini;
	    echo "${aws_instance.nginx-instance[count.index].public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a nginx-instance.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	    ansible-playbook -u ${var.ansible_user}  -vvv --private-key ${var.private_key} -i nginx-instance.ini ./playbooks/nginx_install.yml
    EOT
  }

  tags = {
    Name     = "nginx-instance-${count.index}"
    Location = "N.Virginia"
  }

}

resource "aws_security_group" "nginx-ssh" {
  name        = "nginx-ssh-group"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "nginx-ssh-vpc"
  }
}

resource "aws_security_group" "nginx-web" {
  name        = "nginx-web-group"
  description = "Security group for WAN traffic"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "nginx-web-vpc"
  }
}

resource "aws_security_group" "nginx-egress-tls" {
  name        = "nginx-egress-tls"
  description = "Security group that allows inbound and outbound traffic from all instances in the VPC"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "nginx-egress-tls-vpc"
  }
}

resource "aws_security_group" "nginx-icmp" {
  name        = "nginx-icmp"
  description = "Security group to ping instance"
  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "nginx-icmp-vpc"
  }
}

resource "aws_security_group" "nginx-web-server" {
  name        = "nginx-web-server"
  description = "Security group open port 8080"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-web-server-vpc"
  }
}