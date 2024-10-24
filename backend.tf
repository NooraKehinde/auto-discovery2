terraform {
  backend "s3" {
    bucket         = "euteam20s3bk"
    dynamodb_table = "euteam20db"
    key            = "petauto/terraform.tfstate"
    encrypt        = true
    region         = "eu-west-2"
    profile        = "lead"
  }
}