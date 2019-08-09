resource "tls_private_key" "demo_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo_keys" {
  key_name   = "wp_key"
  public_key = "${tls_private_key.demo_private_key.public_key_openssh}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.aws_disk_image}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

/*
 * Acquire all availability zones and choose one randomly.
 */
data "aws_availability_zones" "available" {
  state = "available"
}