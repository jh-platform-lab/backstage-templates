terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bucket y region del estado se pasan en `terraform init -backend-config=...` (lo hace el CD).
  backend "s3" {
    key          = "${{ values.name }}/terraform.tfstate"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.name
      Owner     = var.owner
      ManagedBy = "terraform"
    }
  }
}
