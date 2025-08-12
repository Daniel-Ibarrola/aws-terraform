output "instance_ip" {
  value = aws_instance.webserver.public_ip
  description = "The instance public IP"
}