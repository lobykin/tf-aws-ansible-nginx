output "url-nginx" {
  value = "http://${aws_instance.nginx-instance.0.public_ip}:8080"
}