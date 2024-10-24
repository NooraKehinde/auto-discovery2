provider "aws" {
  region  = "eu-west-3"
  profile = "lead"
}

provider "vault" {
  token   = "s.kzD670ldbi6i0FLDKuwsQguo"
  address = "http://18.171.233.110:8200/"
}
