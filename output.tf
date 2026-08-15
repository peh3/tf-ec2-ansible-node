resource "local_file" "private_key" {
  content         = tls_private_key.ansible_ec2_key.private_key_pem
  filename        = "${path.module}/${var.demo}-ec2-keypair.pem"
  file_permission = "0600"
}

output "ssh_to_control_node" {
  description = "SSH Command to access Control Server"
  value       = "ssh -i ${var.demo}-ec2-keypair.pem ec2-user@${aws_instance.ansible_control.public_ip}"
}

output "demo_instructions" {
  description = "Cheat sheet of commands for the live presentation"
  value       = <<-EOT

  ==============================================================
  NEXT STEPS FOR LIVE DEMO PRESENTATION
  ==============================================================

  1. SSH into the Control Server:
     ssh -i ${var.demo}-ec2-keypair.pem ec2-user@${aws_instance.ansible_control.public_ip}

  2. Verify Cloud-Init bootstrapping has completed:
     sudo tail -f /var/log/cloud-init-output.log

  3. Navigate to your repository:
     cd ~/ansible-demo-lab

  4. Test Dynamic Inventory discovery:
     ansible-inventory -i inventory/aws_ec2.yml --graph

  5. Execute Day 1 Playbook:
     ansible-playbook -i inventory/aws_ec2.yml playbooks/day1_provision.yml
     ansible-playbook -i inventory/webserver.ini playbooks/day1_provision.yml 
     ansible-playbook -i inventory/aws_ec2.yml playbooks/day1_provision.yml --user ec2-user --ssh-common-args='-o StrictHostKeyChecking=no'

  ==============================================================
  EOT
}