# Containerized Application Infrastructure in AWS

This folder contains the terraform config files to deploy a containerized application to AWS. It uses ECS in fargate mode as
the base for this.

The following architecture is used:

- Cloudfront → ALB (public subnet) → ECS cluster (private subnet)

## Deploying

### Uploading docker images to ECR

First log in to ECR

```shell
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 668144156539.dkr.ecr.us-west-2.amazonaws.com
```

To upload the client image to ECR

```shell
cd apps/client
docker buildx build --platform linux/amd64 -t 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-client:latest .
docker push 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-client
```

To upload the server image

```shell
cd apps/server
docker buildx build --platform linux/amd64 -t 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-server:latest .
docker push 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-server
```

### Infrastructure

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