locals {
  bastion-userdata = <<-EOF
#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "${var.prv_key}" >> /home/ec2-user/.ssh/id_rsa
sudo chmod 400 /home/ec2-user/.ssh/id_rsa
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
sudo yum install mysql-server -y
sudo hostnamectl set-hostname Bastion
EOF
}