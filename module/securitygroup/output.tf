output "asg-sg" {
  value = aws_security_group.asg-sg.id
}

output "nexus-sg" {
  value = aws_security_group.nexus-sg.id
}
output "sonar-sg" {
  value = aws_security_group.sonar-sg.id
}

output "ansible-bastion-sg" {
  value = aws_security_group.ansible-bastion-sg.id
}
output "jenkins-sg" {
  value = aws_security_group.jenkins-sg.id
}

output "RDS-sg" {
  value = aws_security_group.RDS-sg.id
}