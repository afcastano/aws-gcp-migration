# db server ############################
resource "aws_instance" "db" {
  ami = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = [
    "${aws_security_group.db.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.wp_subnet.id}"

  key_name = "${aws_key_pair.demo_keys.key_name}"
  tags {
    Name = "WordPress DB"
    SELECTOR = "db"
  }
}

# I would initialize the vm via user_data attribute, but velostrata does not like it.
# https://stackoverflow.com/questions/57016394/velostrata-migration-from-aws-to-gcp-failed-cloud-instance-boot-failed
resource "null_resource" "db_provisioner" {
  triggers = {
    db_instace = "${aws_instance.db.id}"
  }
  provisioner "remote-exec" {
    scripts = [
      "scripts/init_velostrata.sh",
      "scripts/init_db.sh"
    ]
  }

  connection {
    type        = "ssh"
    private_key = "${tls_private_key.demo_private_key.private_key_pem}"
    host        = "${aws_instance.db.private_ip}"
    user        = "ubuntu"

    bastion_host        = "${aws_eip_association.bastion_eip_assoc.public_ip}"
    bastion_private_key = "${tls_private_key.demo_private_key.private_key_pem}"
    bastion_user        = "ubuntu"

    timeout     = "30s"
  }

  # Try to run this last
  depends_on = ["aws_eip_association.bastion_eip_assoc", "aws_instance.db", "aws_alb_listener.list"]
}

####### SECURITY GROUPS ################
## Private access for DB subnet
resource "aws_security_group" "db" {
  name = "db-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # ssh access from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}