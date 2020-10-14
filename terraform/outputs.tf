output "url-nginx" {
  value = "http://${aws_instance.nginx-instance.0.public_ip}:8080"
}

output "ip" {
 value = aws_instance.nginx-instance[count.index].public_ip
}
