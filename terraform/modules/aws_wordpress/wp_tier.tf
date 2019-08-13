## AWS WP NETWORK ##############################################

#provision wordpress subnet
resource "aws_subnet" "wp_subnet" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.aws_wp_subnet_cidr}"
  tags {
    Name = "WordPress subnet"
  }
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
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

### SECURITY GROUPS #########################

#Private access for WP subnet
resource "aws_security_group" "wp" {
  name = "wp-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # ssh access from bastion
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [
      "${var.aws_pub_subnet_1_cidr}",
      "${var.gcp_public_subnet}", # Public subnet for gcp bastion access
      "${var.gcp_wp_subnet}" # Private subnet for velostrata access
    ]
  }

  # Allow ping from subnets
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [
      "${var.aws_pub_subnet_1_cidr}",
      "${var.gcp_public_subnet}", # Public subnet for gcp bastion access
      "${var.gcp_wp_subnet}" # Private subnet for velostrata access
    ]
  }
  
  # http access from load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${var.aws_pub_subnet_1_cidr}"]
  }

  # https access from gcp network
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = [
      "${var.gcp_wp_subnet}",
      "${var.gcp_public_subnet}" # Public subnet for velostrata access
    ]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
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
      "/tmp/init_wp.sh ${aws_db_instance.wp-db.address} ${var.aws_wp_db_user} ${var.aws_wp_db_password}",
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
  depends_on = ["aws_eip_association.bastion_eip_assoc", "aws_instance.wp", "aws_vpc_dhcp_options_association.dns_resolver"]
  count = 2
}