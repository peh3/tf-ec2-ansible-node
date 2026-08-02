/*resource "aws_instance" "ansible" {
  ami                         = "ami-01edba92f9036f76e" # find the AMI ID of Amazon Linux 2023
  instance_type               = "t2.micro"
  #subnet_id                   = "subnet-07fe08d5909e677db"  #Public Subnet ID, e.g. subnet-xxxxxxxxxxx
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = true
  key_name                    = "tk-ec2-key" #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids = [aws_security_group.ansible.id]

  #user_data = <<-EOF
  #  #cloud-config
  #  users:
  #    - name: ansible-ssh
  #      gecos: AWX Automation Account
  #      groups: sudo, wheel
  #      sudo: ALL=(ALL) NOPASSWD:ALL
  #      shell: /bin/bash
  #      lock_passwd: true
  #      ssh_authorized_keys:
  #        - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqJDiDY+EEJ1L98YkU7/RCBo3rV2DSQNRg68kliAw5k awx-day1-operations"
  #  runcmd:
  #   # Security hardening: ensure proper permissions on the new home directory
  #    - chmod 700 /home/ansible-ssh/.ssh
  #    - chmod 600 /home/ansible-ssh/.ssh/authorized_keys
  #    - chown -R ansible-ssh:ansible-ssh /home/ansible-ssh/.ssh
  #  EOF

  user_data = file("${path.module}/userdata.sh")

  depends_on = [
    aws_route.public_internet
    #, aws_nat_gateway.tk_tf_nat_gw
  ]

  tags = {
    Name = "tk-tf-ec2"    #Prefix your own name, e.g. jazeel-ec2
  }
}

output "public_ip" {
  description = "The public IP address of the main web server."
  value       = aws_instance.ansible.public_ip
}
*/

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
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y python3-pip git htop
              pip3 install ansible-core boto3 botocore
              ansible-galaxy collection install amazon.aws -p /usr/share/ansible/collections
              
              # Store the private SSH key on control node to access managed node
              mkdir -p /home/ec2-user/.ssh
              echo "${tls_private_key.ansible_ec2_key.private_key_pem}" > /home/ec2-user/.ssh/id_rsa
              chmod 600 /home/ec2-user/.ssh/id_rsa
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh

              cd /home/ec2-user
              git clone https://github.com/peh3/tf-ansible-lab.git

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