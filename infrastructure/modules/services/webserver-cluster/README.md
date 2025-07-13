# Webserver Cluster Terraform Module
A Terraform module for deploying a scalable, fault-tolerant web server cluster on AWS using Auto Scaling Groups and Application Load Balancer.

## Features
- Creates an Auto Scaling Group of EC2 instances
- Provisions an Application Load Balancer for traffic distribution
- Configures security groups with proper access controls
- Connects to a database using remote state
- Health checks and auto-scaling capabilities
- Customizable instance type and cluster size

## Requirements

| Name | Version |
| --- | --- |
| terraform | = 1.0 |
| aws | 5.100 |

## Usage

```hcl
module "webserver_cluster" {
  source = "path/to/modules/webserver-cluster"

  cluster_name        = "webservers-prod"
  instance_type       = "t2.micro"
  min_size            = 2
  max_size            = 10
  server_port         = 80
  
  # S3 remote state for database
  db_remote_state_bucket = "terraform-state-bucket"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"
}
```

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| server_port | Port the server uses for HTTP requests | number | 80 | no |
| cluster_name | The name to use for all cluster resources | string | n/a | yes |
| db_remote_state_bucket | The name of the S3 bucket for the remote state | string | n/a | yes |
| db_remote_state_key | The path for the S3 bucket for the database remote state | string | n/a | yes |
| instance_type | The type of the EC2 instances to run | string | n/a | yes |
| min_size | The minimum number of instances in the ASG | number | n/a | yes |
| max_size | The maximum number of instances in the ASG | number | n/a | yes |

## Outputs

| Name | Description |
| --- | --- |
| alb_dns_name | DNS name of the load balancer |
| asg_name | The name of the autoscaling group |
| alb_sg_id | The ID of the ALB security group |
| webserver_sg_ig | The ID of the webserver cluster security group |


## Architecture

This module deploys:
1. **Auto Scaling Group**: Manages EC2 instances with configurable min/max sizes
2. **Launch Template**: Defines the EC2 instance configuration, including the AMI and user data
3. **Application Load Balancer**: Distributes incoming HTTP traffic to the instances
4. **Security Groups**:
    - Load balancer security group: Allows HTTP traffic from anywhere
    - Web server security group: Allows traffic only from the load balancer

## Network Configuration

- Uses the default VPC and subnets
- Instances are deployed across all available subnets in the default VPC
- Load balancer is internet-facing

## Database Integration

The module connects to a MySQL database by fetching connection details from the remote state. The database connection information is passed to the EC2 instances via the user data script.

## Security
- Web servers only accept traffic from the load balancer
- Load balancer accepts HTTP traffic from the internet
- All outbound traffic is allowed

## Notes
- The module uses a fixed AMI ID: `ami-06971c49acd687c30`
- Health check is configured to check the root path () with a 200 response `/`
- User data is loaded from a template file: `user-data.sh.tftpl`
