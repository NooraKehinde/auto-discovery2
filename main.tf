locals {
  name = "pet-auto"
}

data "aws_acm_certificate" "acm-ssl" {
  domain      = "noektech.com"
  types    = ["AMAZON_ISSUED"]
  most_recent = true
}

module "keypair" {
  source        = "./module/keypair"
  prv-file-name = "pet-private-key"
  pub-file-name = "pet-public-key"
  pub_key_name  = "pet-public-key-name" 
}

module "vpc" {
  source           = "./module/vpc"
  cidr             = "10.0.0.0/16"
  public_subnet_1  = "10.0.1.0/24"
  public_subnet_2  = "10.0.3.0/24"
  private_subnet_1 = "10.0.2.0/24"
  private_subnet_2 = "10.0.4.0/24"
  avz1             = "eu-west-3a"
  avz2             = "eu-west-3b"
}


module "RDS" {
source        = "./module/rds-server"
subnet_ids    = [module.vpc.pri_sub1, module.vpc.pri_sub2]
db-identifier = "petclinic"
dbname        = "petclinic"
dbusername    = data.vault_generic_secret.vault_secret.data["username"]
dbpassword    = data.vault_generic_secret.vault_secret.data["password"]
vpc-id        = module.vpc.vpc_id
name          = local.name
}

data "vault_generic_secret" "vault_secret" {
path = "secret/database"
}

module "sonarqube" {
  source        = "./module/sonarqube"
  ubuntu_ami    = "ami-045a8ab02aadf4f88"
  instance_type = "t2.medium"
  subnet_id     = module.vpc.pub_sub1
  pub_key_name  = module.keypair.public_key_id
  sonar-subnets = [module.vpc.pub_sub1, module.vpc.pub_sub1]
  ssl-cert      = data.aws_acm_certificate.acm-ssl.arn
  sonar_name    = "${local.name}-sonar"
  nc-account-id = "4665859"
  nc-api-id     = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  vpc-id        = module.vpc.vpc_id
  name          = local.name
  sonar-domain  = "sonarqube.noektech.com"
  domain        = "noektech.com"
}