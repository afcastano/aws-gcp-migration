#Deploy Wordpress instances

resource "tls_private_key" "demo_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo_keys" {
  key_name   = "wp_key"
  public_key = "${tls_private_key.demo_private_key.public_key_openssh}"
}

/*
 * Acquire all availability zones and choose one randomly.
 */
data "aws_availability_zones" "available" {
  state = "available"
}