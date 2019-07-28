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

# bastion ############################
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = [
    "${aws_security_group.pub.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.pub_subnet_1.id}"

  key_name = "${aws_key_pair.demo_keys.key_name}"
  tags {
    Name = "WordPress Bastion"
    SELECTOR = "bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  depends_on = ["aws_internet_gateway.app_igw"]
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

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

# wp server ############################
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

# LOAD BALANCER ################
resource "aws_alb" "alb" {
  subnets = ["${aws_subnet.pub_subnet_1.id}", "${aws_subnet.pub_subnet_2.id}"]
  internal = false
  security_groups = ["${aws_security_group.pub.id}"]
}

resource "aws_alb_target_group" "targ" {
  port = 8080
  protocol = "HTTP"
  vpc_id = "${aws_vpc.app_vpc.id}"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/"
    interval            = 30
    port                = 80
    matcher             = "200-399"
  }
  stickiness {
    type = "lb_cookie"
    enabled = true
  }
}

resource "aws_alb_target_group_attachment" "attach_web" {
  target_group_arn = "${aws_alb_target_group.targ.arn}"
  target_id = "${element(aws_instance.wp.*.id, count.index)}"
  port = 80
  count = 2
}

resource "aws_alb_listener" "list" {
  "default_action" {
    target_group_arn = "${aws_alb_target_group.targ.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = 80
}