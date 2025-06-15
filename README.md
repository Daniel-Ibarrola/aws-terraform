# Containerized Application Infrastructure in AWS

This repository contains the terraform config files to deploy a containerized application to AWS. It uses ECS in fargate mode as
the base for this.

The following architecture is used:

- Cloudfront → ALB (public subnet) → ECS cluster (private subnet)

## Deploying

To deploy the infrastructure first create the backend for terraform state

```shell
cd ./terraform/backend
terraform init
terraform apply 
```

Now you can init terraform in the terraform directory

```shell
cd ..
terraform init
```

This is only needed the first time. After that run:

```shell
terraform apply
```

To destroy it use 

```shell
terraform destroy
```