#provision webserver subnet
resource "aws_subnet" "web_subnet" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "192.168.20.0/24"
  tags {
    Name = "web server subnet"
  }
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
}

# Web subnet routes for NAT
resource "aws_route_table" "nat-routes" {
    vpc_id = "${aws_vpc.app_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.web-subnet-nat-gw.id}"
    }

    tags {
        Name = "web-subnet-routes-1"
    }
}
resource "aws_route_table_association" "web-subnet-routes" {
    subnet_id = "${aws_subnet.web_subnet.id}"
    route_table_id = "${aws_route_table.nat-routes.id}"
}





#provision database subnet =========================================================
resource "aws_subnet" "db_subnet_1" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "192.168.30.0/24"
  availability_zone = "${var.aws_availability_zone_1}"
  tags {
    Name = "database subnet"
  }
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
}

#provision database subnet
resource "aws_subnet" "db_subnet_2" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "192.168.40.0/24"
  availability_zone = "${var.aws_availability_zone_2}"
  tags {
    Name = "database subnet"
  }
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
}