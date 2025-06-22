variable "server_port" {
  description = "Port the server uses for http requests"
  type = number
  default = 8080
}

resource "aws_security_group" "web_server_sg" {
  name        = "Web Server SG"
  description = "Allow traffic from anywhere to port 8080"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-06971c49acd687c30"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data                   = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  user_data_replace_on_change = true

  tags = {
    Name = "Web Server"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
  description = "The public ip of the web server"
}