provider "aws" {
  region = "eu-west-3"
}

provider "vault" {
  token   = "s.KhkOZRbl0FrBjSzEtRa5Y49W"
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