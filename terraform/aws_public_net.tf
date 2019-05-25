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