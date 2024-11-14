output "sonarqube" {
  value = module.sonarqube.sonarqube_ip
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "subnet_ids" {
  value = [module.vpc.pri_sub1, module.vpc.pri_sub2]
}
