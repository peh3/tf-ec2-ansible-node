#resource "aws_security_group" "allow_ssh" {
#  name        = "tk-terraform-security-group" #Security group name, e.g. jazeel-terraform-security-group
#  description = "Allow SSH inbound"
#  #vpc_id      = "vpc-071dc429d54e64259"  #VPC ID (Same VPC as your EC2 subnet above), E.g. vpc-xxxxxxx
#  vpc_id      = aws_vpc.tk_tf_vpc.id
#}

#resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
#  security_group_id = aws_security_group.allow_ssh.id
#  cidr_ipv4         = "0.0.0.0/0"  
#  from_port         = 22
#  ip_protocol       = "tcp"
#  to_port           = 22
#}

resource "aws_security_group" "ansible" {
  name        = "tk-ansible-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.tk_tf_vpc.id

  # HTTP access
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For production, restrict this to your specific public IP block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}