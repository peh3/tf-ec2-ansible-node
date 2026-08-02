# Save local copy of private key for SSH access from your laptop
resource "local_file" "private_key" {
  content         = tls_private_key.ansible_ec2_key.private_key_pem
  filename        = "${path.module}/${var.demo}-ec2-keypair.pem"
  file_permission = "0600"
}

output "ssh_to_control_node" {
  description = "SSH Command to access Control Server"
  value       = "ssh -i ${var.demo}-ec2-keypair.pem ec2-user@${aws_instance.ansible_control.public_ip}"
}