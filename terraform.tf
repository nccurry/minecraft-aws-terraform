terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.1, < 6.0.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = ">= 0.13.0, < 1.0.0"
    }
  }
}