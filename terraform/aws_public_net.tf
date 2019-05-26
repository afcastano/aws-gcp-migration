#provision public subnet 1
resource "aws_subnet" "pub_subnet_1"{
  
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "192.168.5.0/24"
  tags {
      Name = "public subnet"
  }
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
  availability_zone = "${var.aws_availability_zone_1}"
}

#provision public subnet 2 for LB. It requires multiple AZ
resource "aws_subnet" "pub_subnet_2"{
  
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "192.168.10.0/24"
  tags {
      Name = "public subnet"
  }
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
  availability_zone = "${var.aws_availability_zone_2}"
}

# NAT Gateway configuration for web subnet
resource "aws_eip" "web-subnet-nat-eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.app_igw"]
}
resource "aws_nat_gateway" "web-subnet-nat-gw" {
  allocation_id = "${aws_eip.web-subnet-nat-eip.id}"
  subnet_id = "${aws_subnet.pub_subnet_1.id}"
  depends_on = ["aws_internet_gateway.app_igw"]
}

# LOAD BALANCER ################

#Provision load balancer
resource "aws_alb" "alb" {
  subnets = ["${aws_subnet.pub_subnet_1.id}", "${aws_subnet.pub_subnet_2.id}"]
  internal = false
  security_groups = ["${aws_security_group.lb-sec.id}"]
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
    port                = 8080
    matcher             = "200-399"
  }
  stickiness {
    type = "lb_cookie"
    enabled = true
  }
}

resource "aws_alb_target_group_attachment" "attach_web" {
  target_group_arn = "${aws_alb_target_group.targ.arn}"
  target_id = "${element(aws_instance.web-server.*.id, count.index)}"
  port = 8080
  count = "${var.aws_wp_server_count}"
}

resource "aws_alb_listener" "list" {
  "default_action" {
    target_group_arn = "${aws_alb_target_group.targ.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = 80
}

resource "aws_security_group" "lb-sec" {
  name = "lb-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ping from anywhere
    ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}