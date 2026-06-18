# Use latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

# VM 1: Engine & NGINX
resource "aws_instance" "vm_1_engine" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.api_gateway.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("user_data.sh", {
    NODE_TYPE        = "engine"
    REPO_URL         = var.github_repo_url
    AWS_REGION       = var.aws_region
    ECR_REGISTRY_URL = aws_ecr_repository.engine.repository_url
    ENGINE_IP        = "" # Engine doesn't need to connect to itself
  })

  tags = { Name = "iii-api-gateway" }
}

# VM 2: Caller Worker
resource "aws_instance" "vm_2_caller" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.workers.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("user_data.sh", {
    NODE_TYPE        = "caller"
    REPO_URL         = var.github_repo_url
    AWS_REGION       = var.aws_region
    ECR_REGISTRY_URL = aws_ecr_repository.caller.repository_url
    ENGINE_IP        = aws_instance.vm_1_engine.private_ip # Automatically injects VM 1's IP
  })

  tags = { Name = "caller-worker" }
}

# VM 3: Inference Worker
resource "aws_instance" "vm_3_inference" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium" # 16GB RAM for the ML Model
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.workers.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("user_data.sh", {
    NODE_TYPE        = "inference"
    REPO_URL         = var.github_repo_url
    AWS_REGION       = var.aws_region
    ECR_REGISTRY_URL = aws_ecr_repository.inference.repository_url
    ENGINE_IP        = aws_instance.vm_1_engine.private_ip
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = { Name = "inference-worker" }
}
