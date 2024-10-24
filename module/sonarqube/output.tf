output "sonarqube_ip" {
  value = aws_instance.sonarqube_instance.public_ip
}
output "sonarqube-dns" {
  value = aws_elb.elb-sonar.dns_name
}
output "sonarqube_zone_id" {
  value = aws_elb.elb-sonar.zone_id
}