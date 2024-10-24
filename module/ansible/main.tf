# Ansible server
resource "aws_instance" "ansible_server" {
  ami                         = var.ami-redhat
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.ansible-sg]
  subnet_id                   = var.subnet-id
  key_name                    = var.keypair
  user_data                   = local.ansible_user_data

  tags = {
    Name = var.name
  }
}