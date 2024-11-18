output "sonarqube" {
  value = module.sonarqube.sonarqube_ip
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "nexus" {
  value = module.nexus.nexus_ip
}