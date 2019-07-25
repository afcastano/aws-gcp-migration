### AWS VPC ####################################################################
# provision app vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = "${var.aws_network_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "WP Solution VPC"
  }
}

# create igw
resource "aws_internet_gateway" "app_igw" {
  vpc_id = "${aws_vpc.app_vpc.id}"
}

# add dhcp options
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

# associate dhcp with vpc
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.app_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

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

## AWS PRIVATE NETWORKS ##############################################

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
resource "aws_route_table" "wp-nat-routes" {
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
    route_table_id = "${aws_route_table.wp-nat-routes.id}"
}
