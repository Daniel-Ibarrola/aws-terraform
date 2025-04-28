aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 668144156539.dkr.ecr.us-west-2.amazonaws.com

docker tag my-nginx-test:latest 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/nginx:latest

docker push 668144156539.dkr.ecr.us-west-2.amazonaws.com/tests/nginx:latest