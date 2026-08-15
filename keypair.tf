resource "tls_private_key" "ansible_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible_ec2_keypair" {
  key_name   = "${var.demo}-ec2-keypair"
  public_key = tls_private_key.ansible_ec2_key.public_key_openssh
}