variable "server_port" {
  description = "Port the server uses for http requests"
  type        = number
  default     = 80
}

variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the S3 bucket for the database remote state"
  type        = string
}

variable "instance_type" {
  description = "The type of the EC2 instances to run"
  type        = string
}

variable "min_size" {
  description = "The minimum number of instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of instances in the ASG"
  type        = number
}

variable "custom_tags" {
  description = "Custom tags to set in the instances of the ASG"
  type = map(string)
  default = {}
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for the webserver cluster"
  type = bool
}

variable "ami" {
  description = "The AMI to run in the cluster"
  type = string
  default = "ami-06971c49acd687c30"
}

variable "server_text" {
  description = "The text the server returns"
  type = string
  default = "Hello World"
}