variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"]
}

variable "environment" {
  description = "The environment (QA or Prod)"
  type        = string
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
  description = "Name of the container that will run the app"
  type        = string
  default     = "client-container"
}

variable "domain_name" {
  description = "The root domain name you own (e.g., your-app-domain.com)"
  type        = string
}

variable "subdomain_name" {
  description = "The subdomain part (e.g., 'app' for app.your-app-domain.com, or leave empty/null for root domain)"
  type        = string
}