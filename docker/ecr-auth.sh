aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 668144156539.dkr.ecr.us-west-2.amazonaws.com

docker buildx build --platform linux/amd64 -t 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-client:latest .
docker push 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-client

docker buildx build --platform linux/amd64 -t 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-server:latest .
docker push 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/pet-server