#bastion-host
resource "aws_instance" "bastion" {
  ami                         = var.redhat
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.baston-sg]
  key_name                    = var.pub_key_name
  user_data = local.bastion-userdata
  
  tags = {
    Name = var.bastion_name
  }
}