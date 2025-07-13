# MySQL Database Terraform Module
This Terraform module provisions an AWS RDS MySQL database instance.

## Features
- Creates a MySQL database instance in AWS RDS
- Configurable instance type and storage
- Secure credential management with sensitive variables
- Provides output for connection endpoint and port

## Requirements

| Name | Version |
| --- | --- |
| terraform | N/A |
| aws | 5.100 |

## Usage

```hcl
module "mysql_database" {
  source = "path/to/this/module"

  db_identifier     = "my-database"
  db_name           = "mydatabase"
  db_instance_class = "db.t3.micro"
  db_username       = var.database_username
  db_password       = var.database_password
}
```

## Inputs

| Name | Description | Type | Required |
| --- | --- | --- | --- |
| db_username | The username of the database | string | yes |
| db_password | The password of the database | string | yes |
| db_identifier | An identifier for the database | string | yes |
| db_name | The name of the database to create | string | yes |
| db_instance_class | The instance type that will run the database e.g 'db.t3.micro' | string | yes |
## Outputs

| Name | Description |
| --- | --- |
| address | Connect to the database at this endpoint |
| port | The port the database is listening on |
## Resource Configuration
The module creates an AWS RDS instance with the following configurations:
- Engine: MySQL
- Allocated storage: 10GB
- Skip final snapshot: true (Note: This means no final snapshot will be created when the database is deleted)

## Security Notes
- Database credentials are marked as sensitive to prevent accidental exposure in logs
- Ensure proper security group and network configuration when using this module
- Consider enabling encryption and backups for production use
