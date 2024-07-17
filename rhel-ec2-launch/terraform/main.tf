// save variables in a file `terraform.tfvars` in same directory similar to below:
// $ cat terraform.tfvars
//     vpc_id = "vpc-a01234"
//     base_domain = "test-bootc.com"
//
variable "vpc_id" {
  type = string
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "base_domain" {
  type = string
}

data "aws_route53_zone" "domain" {
  name        = var.base_domain
  private_zone = false
}

data "aws_ami" "rhel9" {
  most_recent = true
  filter {
    name = "name"
    values = ["RHEL-9.3.0_HVM-20240117-x86_64-49-Hourly2-GP3"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

// Create a new elastic ip address
resource "aws_eip" "eip_assoc" {
  domain = "vpc"
}

// Associate elastic ip address with instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.rhel9_test.id
  allocation_id = aws_eip.eip_assoc.id
}

// generate a new security group to allow ssh and https traffic
// these ports are exposed to match the sample AI applications in
// https://github.com/containers/ai-lab-recipes
resource "aws_security_group" "rhel-access" {
  name        = "rhel-access"
  description = "Allow ssh and https traffic"
  vpc_id      = var.vpc_id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "CHATAPP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MODELSERVICE"
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "sshkey" {
  key_name   = uuid()
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "rhel9_test" {
  ami           = data.aws_ami.rhel9.id
  root_block_device {
    volume_size = 90
    volume_type = "gp3"
  }

  //cpu_options {
  //  core_count       = 32
  //  threads_per_core = 1
  //}

  // example arm machine type
  //instance_type = "c6gd.8xlarge"
  // example x86 machine type for AI/ML workloads
  // https://aws.amazon.com/ec2/instance-types/g5/
  //instance_type = "g5.2xlarge"

  // This is .376 USD per Hour. Adjust accordingly
  instance_type = "c3.xlarge"
  vpc_security_group_ids = [aws_security_group.rhel-access.id]
  key_name               = aws_key_pair.sshkey.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "echo 'Connection Established'",
      "sudo dnf -y update",
    ]
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file(var.ssh_private_key_path)
  }
  }

// Output public ip address
output "public_ip" {
  value = aws_eip.eip_assoc.public_ip
}
