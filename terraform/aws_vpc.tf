#provision app vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = "192.168.0.0/16"
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

#default route table 
resource "aws_default_route_table" "default" {
   default_route_table_id = "${aws_vpc.app_vpc.default_route_table_id}"

   route {
       cidr_block = "0.0.0.0/0"
       gateway_id = "${aws_internet_gateway.app_igw.id}"
   }
}