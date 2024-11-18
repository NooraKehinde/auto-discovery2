output "nexus_ip" {
  value = aws_instance.nexus.public_ip
}
output "nexus_dns" {
  value = aws_elb.elb-nexus.dns_name
}
output "nexus_zone_id" {
  value = aws_elb.elb-nexus.zone_id
}
output "nexus_sg_id" {
  value = aws_security_group.nexus_sg.id
}