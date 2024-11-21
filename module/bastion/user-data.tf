locals {
  bastion-userdata = <<-EOF
#!/bin/bash
echo "${var.prv_key}" >> /home/ec2-user/.ssh/id_rsa
sudo chmod 400 /home/ec2-user/.ssh/id_rsa
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
sudo hostnamectl set-hostname Bastion
EOF
}