provider "aws" {
  region  = "eu-west-3"
}

provider "vault" {
  token   = "s.kzD670ldbi6i0FLDKuwsQguo"
  address = "vault.noektech.com"
}

terraform {
  backend "s3" {
    bucket         = "auto-discovery-s3"
    dynamodb_table = "discovery-db"
    key = "vault/terraform.tfstate"
    encrypt = true
    region = "eu-west-3"
    profile = "lead"
  }
}
