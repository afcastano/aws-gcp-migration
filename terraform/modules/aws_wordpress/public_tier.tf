# AWS PUBLIC SUBNET ########################################################
#provision public subnet 1
resource "aws_subnet" "pub_subnet_1"{
  
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.aws_pub_subnet_1_cidr}"
  tags {
      Name = "public subnet"
  }
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

#provision public subnet 2 (Required for load balancer)
resource "aws_subnet" "pub_subnet_2"{
  
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.aws_pub_subnet_2_cidr}"
  tags {
      Name = "public subnet 2"
  }
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

resource "aws_default_route_table" "aws-vpc" {
  default_route_table_id = "${aws_vpc.app_vpc.default_route_table_id}"
  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app_igw.id}"
  }
}

# NAT Gateway configuration for private subnetss
resource "aws_eip" "nat-eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.app_igw"]
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat-eip.id}"
  subnet_id = "${aws_subnet.pub_subnet_1.id}"
  depends_on = ["aws_internet_gateway.app_igw"]
}


#### EC2 INSTANCES #################

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

###### SECURITY GROUP
#public access sg 
resource "aws_security_group" "pub" {
  name = "pub-secgroup"
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