locals {
  name = "pet-auto"
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

#module "RDS" {
  #source        = "./module/rds-server"
  #subnet_ids    = [module.vpc.pri_sub1, module.vpc.pri_sub2]
  #db-identifier = "petclinic"
  #db-sg         = module.securitygroup.RDS-sg
  #dbname        = "petclinic"
  #dbusername    = data.vault_generic_secret.vault_secret.data["username"]
  #dbpassword    = data.vault_generic_secret.vault_secret.data["password"]
#}

#data "vault_generic_secret" "vault_secret" {
#path = "secret/database"
#}