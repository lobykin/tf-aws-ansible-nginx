resource "aws_key_pair" "key_pair_pem" {
  key_name   = "github"
  public_key = file(var.public_key)
}

resource "aws_instance" "nginx-instance" {
  count = var.instance_count
  ami           = var.ami
  instance_type = var.instance
  key_name      = aws_key_pair.key_pair_pem.key_name
  vpc_security_group_ids = [
    aws_security_group.nginx-web.id,
    aws_security_group.nginx-ssh.id,
    aws_security_group.nginx-egress-tls.id,
    aws_security_group.nginx-icmp.id,
	aws_security_group.nginx-web-server.id
  ]

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 500
    volume_type           = "io1"
    iops                  = 2000
    encrypted             = true
    delete_on_termination = true
  }

  connection {
    private_key = file(var.private_key)
    user        = var.ansible_user
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python -y"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 600;
	  >nginx-instance.ini;
	  echo "[nginx-instance]" | tee -a nginx-instance.ini;
	  echo aws_instance.nginx-instance.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a nginx-instance.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i nginx-instance.ini ../ansible/nginx_install.yaml
    EOT
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
  tags {
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
  tags {
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
  tags {
    Name = "nginx-egress-tls-vpc"
  }
}

resource "aws_security_group" "nginx-icmp" {
  name        = "default-ping-example"
  description = "Security group to ping instance"
  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
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

  tags {
    Name = "nginx-web-server-vpc"
  }
}