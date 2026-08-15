# tf-ec2-ansible-node

AWS EC2 + Terraform Infrastructure Deployment

This project demonstrates how to provision an automated two-node AWS lab environment using:
* Amazon EC2 (Amazon Linux 2023)
* AWS IAM (Instance Profile with AmazonEC2ReadOnlyAccess)
* TLS Private Key / SSH Key Pair Automation
* User Data Cloud-Init Automation
* Remote State Management (AWS S3 Backend)
* Terraform Infrastructure-as-Code

## Architecture

Terraform provisions an Ansible Control Node and an Ansible Target Node within a custom VPC in `us-east-1`. The Control Node is attached to an IAM Instance Profile (`AmazonEC2ReadOnlyAccess`) and bootstrapped via `user_data` to install Ansible Core, Python dependencies (`boto3`, `botocore`), the `amazon.aws` collection, and clone the `ansible-demo-lab` repository. Both instances share a Security Group allowing SSH (port 22) and HTTP (port 80) access, using an auto-generated TLS keypair.

```text
+-----------------------------------------------------------------------------------------------------------------------------------------+
|                                                          AWS REGION: US-EAST-1                                                          |
|                                                                                                                                         |
|   +---------------------------------------------------------------------------------------------------------------------------------+   |
|   |                                                           DEMO VPC                                                              |   |
|   |                                                                                                                                 |   |
|   |   +-------------------------------------------------+                             +-----------------------------------------+   |   |
|   |   | INSTANCE 1: ANSIBLE CONTROL SERVER              |                             | INSTANCE 2: MANAGED TARGET NODE         |   |   |
|   |   | (Amazon Linux 2023)                             |                             | (Amazon Linux 2023)                     |   |   |
|   |   | Tag: Environment = ${var.demo}                  \vert{}                             \vert{} Tag: Environment =${var.demo}          |   |   |
|   |   | Tag: Role = ${var.demo}-control_node            \vert{}                             \vert{} Tag: Role =${var.demo}-webserver       |   |   |
|   |   |                                                 |                             |                                         |   |   |
|   |   | [IAM Role: AmazonEC2ReadOnlyAccess]             |                             | [Day 1 Ansible Configured Software]     |   |   |
|   |   | [Software: Ansible Core, boto3, Git]            |                             | - Apache HTTP Server (Port 80)          |   |   |
|   |   | [Local Repo: ~/ansible-demo-lab]                |                             | - Custom index.html landing page        |   |   |
|   |   | [SSH Key: ~/.ssh/id_rsa]                        |                             | - Base system utilities                 |   |   |
|   |   +-------------------------------------------------+                             +-----------------------------------------+   |   |
|   |                            |                                                                           ^                            |   |
|   |                            | (1) Query EC2 API                                                         |                            |   |
|   |                            |     describe-instances                                                    | (3) Execute Playbook       |   |
|   |                            v                                                                           |     via SSH (Port 22)      |   |
|   |                   +-----------------+                                                                  |                            |   |
|   |                   |  AWS EC2 APIs   |                                                                  |                            |   |
|   |                   +-----------------+                                                                  |                            |   |
|   |                            |                                                                           |                            |   |
|   |                            | (2) Returns Dynamic Inventory:                                            |                            |   |
|   |                            |     - @role_${var.demo}_control_node                                      |                            |   |
|   |                            |     - @role_${var.demo}_webserver ----------------------------------------+                            |   |
|   |                                                                                                                                     |   |
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
```

## Steps for demo:
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
