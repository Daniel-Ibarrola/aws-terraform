variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "The environment (QA or Prod)"
  type        = string
  default     = "QA"
}

variable "app_port" {
  description = "The port where the client app will run"
  type        = number
  # TODO: make sure port is ok
  default = 80
}

variable "app_image_uri" {
  description = "The full ECR URI of the application image to deploy"
  type        = string
  # Make sure this variable is populated when running terraform apply
  # e.g., terraform apply -var="app_image_uri=123456789012.dkr.ecr.us-west-2.amazonaws.com/ats-client:commitsha"
}

variable "desired_task_count" {
  description = "Number of application tasks to run"
  type        = number
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate Task CPU units (e.g., 256, 512, 1024)"
  type        = number
  default     = 512
}

variable "fargate_memory" {
  description = "Fargate Task Memory MiB (e.g., 512, 1024, 2048)"
  type        = number
  default     = 1024
}

variable "container_name" {
  description = "Name of the container that will run the ATS client"
  type        = string
  default     = "ats-client-container"
}

variable "domain_name" {
  description = "The root domain name you own (e.g., your-app-domain.com)"
  type        = string
  # TODO: update domain name
  default = "servicios-cires.net"
}

variable "subdomain_name" {
  description = "The subdomain part (e.g., 'app' for app.your-app-domain.com, or leave empty/null for root domain)"
  type        = string
  # TODO: update subdomain name
  default     = "test-ecs"
}