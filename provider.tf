provider "aws" {
  region = "eu-west-3"
}

provider "vault" {
  token   = "s.lbY3jjOI6E74hv6hfD0DTnFg"
  address = "https://vault.noektech.com"
}

terraform {
  backend "s3" {
    bucket         = "auto-discovery-s3"
    dynamodb_table = "discovery-db"
    key            = "infrastructure/terraform.tfstate"
    encrypt        = true
    region         = "eu-west-3"
    profile        = "default"
  }
}