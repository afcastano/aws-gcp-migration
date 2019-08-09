## AWS PRIVATE NETWORK ##############################################

#provision wordpress subnet
resource "aws_subnet" "wp_subnet" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.aws_wp_subnet_cidr}"
  tags {
    Name = "WordPress subnet"
  }
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
}

# WP subnet routes for NAT
resource "aws_route_table" "wp-subnet-routes" {
    vpc_id = "${aws_vpc.app_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
    }

    tags {
        Name = "web-subnet-routes-1"
    }
}
resource "aws_route_table_association" "wp-subnet-routes" {
    subnet_id = "${aws_subnet.wp_subnet.id}"
    route_table_id = "${aws_route_table.wp-subnet-routes.id}"
}

# WP SERVERS ############################
resource "aws_instance" "wp" {
  ami = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = [
    "${aws_security_group.wp.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.wp_subnet.id}"

  key_name = "${aws_key_pair.demo_keys.key_name}"
  tags {
    Name = "wp-server-${count.index}"
    SELECTOR = "wp"
  }

  count = 2
}

# I would initialize the vm via user_data attribute, but velostrata does not like it.
# https://stackoverflow.com/questions/57016394/velostrata-migration-from-aws-to-gcp-failed-cloud-instance-boot-failed
resource "null_resource" "wp_provisioner" {
  triggers = {
    wp_instace = "${element(aws_instance.wp.*.private_ip, count.index)}"
  }
  provisioner "file" {
    source      = "scripts/init_velostrata.sh"
    destination = "/tmp/init_velostrata.sh"
  }
  provisioner "file" {
    source      = "scripts/init_wp.sh"
    destination = "/tmp/init_wp.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init_velostrata.sh",
      "chmod +x /tmp/init_wp.sh",
      "/tmp/init_velostrata.sh",
      "/tmp/init_wp.sh ${aws_instance.db.private_ip}",
    ]
  }

  connection {
    type                = "ssh"
    private_key         = "${tls_private_key.demo_private_key.private_key_pem}"
    host                = "${element(aws_instance.wp.*.private_ip, count.index)}"
    user                = "ubuntu"
    bastion_host        = "${aws_eip.bastion_eip.public_ip}"
    bastion_private_key = "${tls_private_key.demo_private_key.private_key_pem}"
    bastion_user        = "ubuntu"
    timeout             = "30s"
  }
  depends_on = ["null_resource.db_provisioner"]
  count = 2
}

### SECURITY GROUPS #########################

#Private access for WP subnet
resource "aws_security_group" "wp" {
  name = "wp-secgroup"
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