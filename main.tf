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
  name             = local.name
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

module "nexus" {
  source         = "./module/nexus"
  redhat_ami     = "ami-0574a94188d1b84a1"  
  instance_type  = "t2.medium"
  ssl_cert       = data.aws_acm_certificate.acm-ssl.arn   
  nexus_name     = "${local.name}-nexus"
  nc_account_id  = "4665859"
  nc_api_id      = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  vpc_id         = module.vpc.vpc_id
  name           = local.name
  nexus_domain   = "nexus.noektech.com"
  domain         = "noektech.com"
  nexus_subnets  = [module.vpc.pub_sub1, module.vpc.pub_sub2] 
  pub_key_name   = module.keypair.public_key_id  
  subnet_id      = module.vpc.pub_sub1
} 

module "jenkins" {
  source          = "./module/jenkins-server"
  redhat_ami      = "ami-0574a94188d1b84a1"
  instance_type   = "t2.medium"
  ssl_cert        = data.aws_acm_certificate.acm-ssl.arn
  jenkins_name    = "${local.name}-jenkins"
  pub_key_name    = module.keypair.public_key_id
  nexus_ip        = module.nexus.nexus_ip
  jenkins_subnets = [module.vpc.pub_sub1, module.vpc.pub_sub1]
  subnet_id       = module.vpc.pub_sub1
  nr_key          = "4665859"
  nr_account_id   = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  vpc_id          = module.vpc.vpc_id
  name            = local.name
  jenkins_domain  = "jenkins.noektech.com"
  domain          = "noektech.com"
}

module "ansible" {
  source          = "./module/ansible"
  ami_redhat      = "ami-0574a94188d1b84a1"
  instance_type   = "t2.medium"
  subnet_id       = module.vpc.pri_sub1
  stage-playbook  = "${path.root}/module/ansible/stage-playbook.yml"
  prod-playbook   = "${path.root}/module/ansible/prod-playbook.yml"
  prod-discovery  = "${path.root}/module/ansible/prod-discovery.sh"
  stage-discovery = "${path.root}/module/ansible/stage-discovery.sh"
  privatekey      = module.keypair.private_key_pem
  keypair         = module.keypair.public_key_id
  nc-account-id   = "4665859"
  nc-api-id       = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  name            = "${local.name}-ansible"
  vpc_id          = module.vpc.vpc_id
  pub_key_name    = module.keypair.public_key_id
  nexus-ip        = module.nexus.nexus_ip
}

module "bastion" {
  source          = "./module/bastion"
  redhat_ami      = "ami-0574a94188d1b84a1"
  pub_key_name    = module.keypair.public_key_id
  subnet_id       = module.vpc.pub_sub1
  vpc_id          = module.vpc.vpc_id
  name            = local.name
  prv_key         = module.keypair.private_key_pem
}