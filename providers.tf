//
//Check provider version. Set Region
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}