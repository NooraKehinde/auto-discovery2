provider "aws" {
  region = "eu-west-3"
  profile = "team-20"
}

// Create S3 Bucket 
resource "aws_s3_bucket" "euteam20bk" {
  bucket = "euteam20s3bk"
  force_destroy = true

  tags = {
    Name        = "euteam20-bucket"
  }
}

// create Dynamo Table
resource "aws_dynamodb_table" "euteam20db" {
  name             = "euteam20db"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}