//Getting ip adress as an Terraform Apply output

output "ip" {
 value = aws_instance.nginx-instance[0].public_ip
}