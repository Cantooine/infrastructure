terraform {
  required_version = ">= 1.5.0, < 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0, < 5.32.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
