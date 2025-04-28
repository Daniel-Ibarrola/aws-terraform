variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "app_port" {
  description = "The port where the client app will run"
  type        = number
  default     = 3000
}