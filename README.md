# terraform-ec2-infra

+-----------------------------------------------------------------------------------------------------------------------------------------+
|                                                          AWS REGION: US-EAST-1                                                          |
|                                                                                                                                         |
|   +---------------------------------------------------------------------------------------------------------------------------------+   |
|   |                                                           DEMO VPC                                                              |   |
|   |                                                                                                                                 |   |
|   |   +-------------------------------------------------+                             +-----------------------------------------+   |   |
|   |   | INSTANCE 1: ANSIBLE CONTROL SERVER              |                             | INSTANCE 2: MANAGED TARGET NODE         |   |   |
|   |   | (Amazon Linux 2023)                             |                             | (Amazon Linux 2023)                     |   |   |
|   |   | Tag: Environment = Demo                         |                             | Tag: Environment = Demo                 |   |   |
|   |   | Tag: Role = tk_ansible_demo_control_node        |                             | Tag: Role = tk_ansible_demo_webserver   |   |   |
|   |   |                                                 |                             |                                         |   |   |
|   |   | [IAM Role: EC2ReadOnlyAccess]                   |                             | [Day 1 Ansible Configured Software]     |   |   |
|   |   | [Software: Ansible Core, boto3, Git]            |                             | - Nginx Web Server (Port 80)            |   |   |
|   |   | [Local Repo: ~/tf-ansible-lab]                  |                             | - Custom index.html landing page        |   |   |
|   |   | [SSH Key: ~/.ssh/id_rsa (tk-tf-keypair)]        |                             | - Base utils (curl, htop)               |   |   |
|   |   +-------------------------------------------------+                             +-----------------------------------------+   |   |
|   |                            |                                                                           ^                        |   |
|   |                            | (1) Query EC2 API                                                         |                        |   |
|   |                            |     describe-instances                                                    | (3) Execute Playbook   |   |
|   |                            v                                                                           |     via SSH (Port 22)  |   |
|   |                   +-----------------+                                                                  |     using tk-tf-keypair|   |
|   |                   |  AWS EC2 APIs   |                                                                  |                        |   |
|   |                   +-----------------+                                                                  |                        |   |
|   |                            |                                                                           |                        |   |
|   |                            | (2) Returns Inventory:                                                    |                        |   |
|   |                            |     - @role_tk_ansible_demo_control_node                                  |                        |   |
|   |                            |     - @role_tk_ansible_demo_webserver                                     |                        |   |
|   |                            +---------------------------------------------------------------------------+                        |   |
|   |                                                                                                                                 |   |
|   +---------------------------------------------------------------------------------------------------------------------------------+   |
+-----------------------------------------------------------------------------------------------------------------------------------------+
                                        ^                                                                   ^
                                        |                                                                   |
                            (Terraform: terraform apply)                                              (Verification)
                                        |                                                                   |
                         +-----------------------------+                                     +-----------------------------+
                         |      LOCAL LAPTOP / CLI     |                                     |     WEB BROWSER / TERMINAL  |
                         |  (SSH Terminal & Terraform) |                                     |   curl http://<MANAGED_IP>  |
                         +-----------------------------+                                     +-----------------------------+
						 

Steps for demo:
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