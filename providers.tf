# AWS Provider Configuration
# This sets up the AWS provider with default tags for all resources.

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Owner       = var.owner
      Environment = var.environment_name
    }
  }
}