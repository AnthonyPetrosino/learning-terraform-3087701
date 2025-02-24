terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {  # Recourse info
  region  = "us-west-2"
}
