output "jenkins_ip" {
  value = aws_instance.Jenkins.public_ip
}

output "jenkins-dns" {
  value = aws_elb.elb-jenkins.dns_name
}

output "jenkins_zone_id" {
  value = aws_elb.elb-jenkins.zone_id
}

output "instance_id" {
  value = aws_instance.Jenkins.id
}