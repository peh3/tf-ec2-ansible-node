resource "aws_instance" "ansible" {
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