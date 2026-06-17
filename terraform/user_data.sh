#!/bin/bash
# This script runs automatically when the EC2 VM boots up.

# 1. Install Docker and Git
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose git awscli

# 2. Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# 3. Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# 4. Clone the configuration repository
cd /home/ubuntu
git clone ${REPO_URL} quickstart
cd quickstart

# 5. Login to AWS ECR securely using the IAM Instance Profile attached to this VM
aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${ECR_REGISTRY_URL}

# 6. Run the specific container based on the VM type
if [ "${NODE_TYPE}" == "engine" ]; then
  sudo docker-compose -f docker-compose.iii.yml up -d
elif [ "${NODE_TYPE}" == "caller" ]; then
  # Inject the III_URL environment variable for the worker
  export III_URL="ws://${ENGINE_IP}:80/ws"
  sudo -E docker-compose -f docker-compose.caller.yml up -d
elif [ "${NODE_TYPE}" == "inference" ]; then
  export III_URL="ws://${ENGINE_IP}:80/ws"
  sudo -E docker-compose -f docker-compose.inference.yml up -d
fi
