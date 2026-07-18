#cloud-config
users:
  - default
  - name: ansible-ssh
    gecos: AWX Automation Account
    groups: [sudo, wheel]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqJDiDY+EEJ1L98YkU7/RCBo3rV2DSQNRg68kliAw5k ec2-day1-operations"
