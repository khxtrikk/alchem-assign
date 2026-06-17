variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "github_repo_url" {
  description = "The public HTTPS URL of your GitHub repository so the VMs can download the config files"
  type        = string
  default     = "https://github.com/YOUR_USERNAME/YOUR_REPO.git"
}
