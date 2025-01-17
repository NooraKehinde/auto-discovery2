output "sonarqube" {
  value = module.sonarqube.sonarqube_ip
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "nexus" {
  value = module.nexus.nexus_ip
}
output "jenkins" {
  value = module.jenkins.jenkins_ip
}
output "ansible" {
  value = module.ansible.ansible_ip
}
output "bastion" {
  value = module.bastion.bastion_ip
}