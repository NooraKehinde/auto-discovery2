locals {
  name = "pet-auto"
}
data "aws_acm_certificate" "acm-ssl" {
  domain      = "hullerdata.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
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

module "keypair" {
  source        = "./module/keypair"
  prv-file-name = "pet-private-key"
  pub-file-name = "pet-public-key"
}

module "securitygroup" {
  source = "./module/securitygroup"
  vpc-id = module.vpc.vpc_id

}
module "sonarqube" {
  source        = "./module/sonarqube"
  ubuntu_ami    = "ami-04a92520784b93e73"
  instance_type = "t2.medium"
  subnet_id     = module.vpc.pub_sub1
  sonarqube-sg  = module.securitygroup.sonar-sg
  pub_key_name  = module.keypair.public_key_id
  sonar-subnets = [module.vpc.pub_sub1, module.vpc.pub_sub1]
  ssl-cert      = data.aws_acm_certificate.acm-ssl.arn
  sonar_name    = "${local.name}-sonar"
  nc-account-id = "4665859"
  nc-api-id     = "NRAK-81TCYY878G65T6NFF8468N8J4W1"

}

module "nexus" {
  source        = "./module/nexus"
  redhat_ami    = "ami-0574a94188d1b84a1"
  instance_type = "t2.medium"
  nexus-sg      = module.securitygroup.nexus-sg
  pub-subnet-id = module.vpc.pub_sub1
  key_pair      = module.keypair.public_key_id
  nexus-subnets = [module.vpc.pub_sub1, module.vpc.pub_sub1]
  ssl-cert      = data.aws_acm_certificate.acm-ssl.arn
  nexus-name    = "${local.name}-nexus"
  nc-account-id = "4665859"
  nc-api-id     = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
}

module "bastion" {
  source       = "./module/bastion"
  redhat       = "ami-0574a94188d1b84a1"
  subnet_id    = module.vpc.pub_sub1
  prv_key      = module.keypair.private_key_pem
  pub_key_name = module.keypair.public_key_id
  bastion_name = "${local.name}-bastion"
  baston-sg    = module.securitygroup.ansible-bastion-sg
}

module "jenkins" {
  source          = "./module/jenkins-server"
  redhat_ami      = "ami-0574a94188d1b84a1"
  instance_type   = "t2.medium"
  jenkins-sg      = module.securitygroup.jenkins-sg
  pub_subnet      = module.vpc.pub_sub1
  keypair         = module.keypair.public_key_id
  jenkins-name    = "${local.name}-jenkins"
  nexus-ip        = module.nexus.nexus_ip
  jenkins-subnets = [module.vpc.pub_sub1, module.vpc.pub_sub1]
  ssl-cert        = data.aws_acm_certificate.acm-ssl.arn
  nr-key          = "4665859"
  nr-acc-id       = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  nr-region       = "eu"
}

module "ansible" {
  source          = "./module/ansible"
  ami-redhat      = "ami-0574a94188d1b84a1"
  ansible-sg      = module.securitygroup.ansible-bastion-sg
  subnet-id       = module.vpc.pri_sub1
  stage-playbook  = "${path.root}/module/ansible/stage-playbook.yml"
  prod-playbook   = "${path.root}/module/ansible/production-playbook.yml"
  prod-discovery  = "${path.root}/module/ansible/prod-discovery.sh"
  stage-discovery = "${path.root}/module/ansible/stage-discovery.sh"
  privatekey      = module.keypair.private_key_pem
  nexus-ip        = module.nexus.nexus_ip
  keypair         = module.keypair.public_key_id
  nc-account-id   = "4665859"
  nc-api-id       = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  name            = "${local.name}-ansible"
}

module "RDS" {
  source        = "./module/rds-server"
  subnet_ids    = [module.vpc.pri_sub1, module.vpc.pri_sub2]
  db-identifier = "petclinic"
  db-sg         = module.securitygroup.RDS-sg
  dbname        = "petclinic"
  dbusername    = "admin"    #data.vault_generic_secret.vault_secret.data["username"]
  dbpassword    = "admin123" #data.vault_generic_secret.vault_secret.data["password"]
}

# data "vault_generic_secret" "vault_secret" {
#  path = "secret/database"
# }

module "acm" {
  source            = "./module/acm"
  domain            = "hullerdata.com"
  jenkins-domain    = "jenkins.hullerdata.com"
  jenkins-dns_name  = module.jenkins.jenkins-dns
  jenkins-zone_id   = module.jenkins.jenkins_zone_id
  sonar-domain      = "sonar.hullerdata.com"
  sonar-dns_name    = module.sonarqube.sonarqube-dns
  sonar-zone_id     = module.sonarqube.sonarqube_zone_id
  nexus-domain      = "nexus.hullerdata.com"
  nexus-dns_name    = module.nexus.nexus-dns
  nexus-zone_id     = module.nexus.nexus_zone_id
  stage-domain      = "stage.hullerdata.com"
  stage-LB-dns_name = module.stage-alb.stage-dns
  stage-LB-zone_id  = module.stage-alb.stage-zone-id
  prod-domain       = "prod.hullerdata.com"
  prod-LB-dns_name  = module.prod-alb.prod-dns
  prod-LB-zone_id   = module.prod-alb.prod-zone-id
}

module "prod-asg" {
  source              = "./module/prod-asg"
  ami-prd             = "ami-0574a94188d1b84a1"
  asg-sg              = module.securitygroup.asg-sg
  key_pair            = module.keypair.public_key_id
  nexus-ip            = module.nexus.nexus_ip
  nr-acc-id           = "4665859"
  nr-key              = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  vpc_zone_identifier = [module.vpc.pri_sub1, module.vpc.pri_sub2]
  prod-tg             = module.prod-alb.prod-tg-arn
  asg-prd-name        = "${local.name}-prod-asg"
}

module "stage-asg" {
  source              = "./module/stage-asg"
  ami-stg             = "ami-0574a94188d1b84a1"
  asg-sg              = module.securitygroup.asg-sg
  key_pair            = module.keypair.public_key_id
  nexus-ip            = module.nexus.nexus_ip
  nr-acc-id           = "4665859"
  nr-key              = "NRAK-81TCYY878G65T6NFF8468N8J4W1"
  vpc_zone_identifier = [module.vpc.pri_sub1, module.vpc.pri_sub2]
  stage-tg            = module.stage-alb.stage-tg-arn
  asg-stg-name        = "${local.name}-stage-asg"
}

module "prod-alb" {
  source      = "./module/prod-lb"
  vpc         = module.vpc.vpc_id
  prod-sg     = [module.securitygroup.asg-sg]
  prod-subnet = [module.vpc.pub_sub1, module.vpc.pub_sub2]
  ssl-cert    = data.aws_acm_certificate.acm-ssl.arn
}

module "stage-alb" {
  source       = "./module/stage-lb"
  vpc          = module.vpc.vpc_id
  stage-sg     = [module.securitygroup.asg-sg]
  stage-subnet = [module.vpc.pub_sub1, module.vpc.pub_sub2]
  ssl-cert     = data.aws_acm_certificate.acm-ssl.arn
}