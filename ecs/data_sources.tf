data "aws_vpc" "target_vpc" {
  filter {
    name   = "tag:Name"
    values = ["Applicant Tracking System qa VPC"]
  }
}

data "aws_subnets" "ats_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.target_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["ats-private-subnet-*"]
  }
}

data "aws_subnets" "ats_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.target_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["ats-public-subnet-*"]
  }
}

data "aws_route_tables" "ats_private_rts" {
  vpc_id = data.aws_vpc.target_vpc.id
  filter {
    name   = "tag:Name"
    values = ["private-route-table"]
  }
}

data "aws_route53_zone" "primary" {
  name         = trimsuffix(var.domain_name, ".") # Ensure no trailing dot
  private_zone = false
}

# --- Check if subnets were found ---
# This will cause Terraform plan/apply to fail if no matching subnets are found
resource "null_resource" "validate_subnets_found" {
  triggers = {
    private_subnet_count = length(data.aws_subnets.ats_private_subnets.ids) > 0 ? "valid" : "error: no private subnets found matching pattern ats-private-subnet_*"
    public_subnet_count  = length(data.aws_subnets.ats_public_subnets.ids) > 0 ? "valid" : "error: no public subnets found matching pattern ats-public-subnet*"
  }

  # Use lifecycle rule to ensure this check passes before proceeding
  lifecycle {
    postcondition {
      condition     = self.triggers.private_subnet_count == "valid"
      error_message = self.triggers.private_subnet_count
    }
    postcondition {
      condition     = self.triggers.public_subnet_count == "valid"
      error_message = self.triggers.public_subnet_count
    }
  }
}