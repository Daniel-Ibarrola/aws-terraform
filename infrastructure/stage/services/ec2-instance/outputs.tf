output "us_east_instance_public_ip" {
  value = module.ec2_instance_us_east.instance_ip
  description = "The public IP of the us-east-1 instance"
}

output "us_west_instance_public_ip" {
  value = module.ec2_instance_us_west.instance_ip
  description = "The public IP of the us-west-1 instance"
}