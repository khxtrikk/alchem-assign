terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ECR Repositories for your Docker Images
resource "aws_ecr_repository" "engine" {
  name         = "iii-engine"
  force_delete = true
}
resource "aws_ecr_repository" "caller" {
  name         = "caller-worker"
  force_delete = true
}
resource "aws_ecr_repository" "inference" {
  name         = "inference-worker"
  force_delete = true
}
