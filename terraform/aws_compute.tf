#Deploy Wordpress instances

#Reference to bash script which prepares xenial image
data "template_file" "wp_config_tmpl"{
  template = "${file("./aws_cloudconfig/wp_config.cfg")}"

  vars {
    db_ip = "${aws_db_instance.wpdb.address}"
    db_user = "${var.aws_wp_db_user}"
    db_password = "${var.aws_wp_db_password}"
  }
}

data "template_cloudinit_config" "wp_config" {
  gzip = false
  base64_encode = false

  part {
    filename     = "aws_cloudconfig/wp_config.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.wp_config_tmpl.rendered}"
  }
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

resource "aws_instance" "web-server" {
  ami = "${data.aws_ami.ubuntu.id}"
  # The public SG is added for SSH and ICMP
  vpc_security_group_ids = [
    "${aws_security_group.web-sec.id}",
    "${aws_security_group.allout.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.wp_subnet.id}"

  tags {
    Name = "web-server-${count.index}"
  }
  count = "${var.aws_wp_server_count}"
  depends_on = ["aws_db_instance.wpdb"]
  user_data = "${data.template_cloudinit_config.wp_config.rendered}"
}

# bastion server
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  # The public SG is added for SSH and ICMP
  vpc_security_group_ids = [
    "${aws_security_group.pub.id}",
    "${aws_security_group.allout.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.pub_subnet_1.id}"

  tags {
    Name = "WordPress Bastion"
  }
  user_data = "${file("aws_cloudconfig/bastion_config.cfg")}"
}

resource "aws_eip" "bastion_eip" {
  depends_on = ["aws_internet_gateway.app_igw"]
}

resource "aws_eip_association" "myapp_eip_assoc" {
  instance_id = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

resource "aws_security_group" "web-sec" {
  name = "webserver-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # Internal HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #ssh from anywhere (for debugging)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#public access sg 
resource "aws_security_group" "pub" {
  name = "pub-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # ssh access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allout" {
  name = "allout-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}