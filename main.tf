resource "aws_instance" "ansible_control" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.ansible_ec2_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.demo_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ansible_control_profile.id
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_1a.id

  # Bootstrapping the Control Node with Ansible & Python dependencies
                #pip3 install ansible boto3 botocore
                #ansible-core
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y python3-pip git htop
              pip3 install ansible boto3 botocore
              ansible-galaxy collection install amazon.aws -p /usr/share/ansible/collections
              
              # Store the private SSH key on control node to access managed node
              mkdir -p /home/ec2-user/.ssh
              echo "${tls_private_key.ansible_ec2_key.private_key_pem}" > /home/ec2-user/.ssh/id_rsa
              chmod 600 /home/ec2-user/.ssh/id_rsa
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh

              cd /home/ec2-user
              git clone https://github.com/peh3/ansible-demo-lab.git

              chown -R ec2-user:ec2-user /home/ec2-user
              EOF

  tags = {
    Name        = "${var.demo}-ansible-control-node"
    Environment = "${var.demo}"
    Role        = "${var.demo}-control_node"
  }
}

resource "aws_instance" "ansible_target" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.ansible_ec2_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.demo_sg.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_1a.id

  tags = {
    Name        = "${var.demo}-ansible-target-node"
    Environment = "${var.demo}"
    Role        = "${var.demo}-webserver"
  }
}