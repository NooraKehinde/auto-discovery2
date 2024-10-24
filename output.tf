output "bastion" {
  value = module.bastion.bastion_ip
}
output "ansible" {
  value = module.ansible.ansible_ip
}
output "jenkins" {
  value = module.jenkins.jenkins_ip
}
output "sonarqube" {
  value = module.sonarqube.sonarqube_ip
}
output "nexus" {
  value = module.nexus.nexus_ip
}