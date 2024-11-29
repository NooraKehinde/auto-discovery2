#bastion-host
resource "aws_instance" "bastion" {
  ami                         = var.redhat_ami
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.pub_key_name
  user_data = local.bastion-userdata
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  
  tags = {
    Name = var.name
  }
}

# Security Group for Bastion
resource "aws_security_group" "bastion_sg" {
  name        = "${var.name}-bastion-sg"
  description = "Allow inbound and outbound traffic for Bastion"
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
    Name = "${var.name}-bastion-sg"
  }
}

