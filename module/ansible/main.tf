# Ansible server
resource "aws_instance" "ansible_server" {
  ami                         = var.ami_redhat
  instance_type               = "t2.medium"
  subnet_id                   = var.subnet_id
  key_name                    = var.keypair
  user_data                   = local.ansible_user_data
  vpc_security_group_ids      = [aws_security_group.ansible_sg.id]

  tags = {
    Name = var.name
  }
}

# Security Group for Ansible
resource "aws_security_group" "ansible_sg" {
  name        = "${var.name}-ansible-sg"
  description = "Allow inbound and outbound traffic for Ansible"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ansible-sg"
  }
}