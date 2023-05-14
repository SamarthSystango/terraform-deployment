resource "aws_instance" "docker" {
  ami = var.aws_ami_id
  instance_type = var.aws_instance_type
  key_name = var.aws_key_pair_name
  security_groups = ["default"]

  user_data = <<EOF
#!/bin/bash

# Install SSH
sudo apt-get update
sudo apt-get install -y openssh-server

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce
EOF
}
