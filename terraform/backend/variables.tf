variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "bucket_name" {
  type    = string
  default = "terraform-state"
}

variable "dynamodb_table_name" {
  type    = string
  default = "terraform-locks"
}