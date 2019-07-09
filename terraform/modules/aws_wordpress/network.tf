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

#default route table 
resource "aws_default_route_table" "default" {
   default_route_table_id = "${aws_vpc.app_vpc.default_route_table_id}"

   route {
       cidr_block = "0.0.0.0/0"
       gateway_id = "${aws_internet_gateway.app_igw.id}"
   }

    # # Attach the propagated routes from the vpn to this route table.
    # propagating_vgws = [
    #   "${aws_vpn_gateway.aws-vpn-gw.id}"
    # ]
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
  availability_zone = "${var.availability_zone}"
}

# NAT Gateway configuration for web subnet
# resource "aws_eip" "web-subnet-nat-eip" {
#   vpc      = true
#   depends_on = ["aws_internet_gateway.app_igw"]
# }
# resource "aws_nat_gateway" "web-subnet-nat-gw" {
#   allocation_id = "${aws_eip.web-subnet-nat-eip.id}"
#   subnet_id = "${aws_subnet.pub_subnet_1.id}"
#   depends_on = ["aws_internet_gateway.app_igw"]
# }

# # Web subnet routes for NAT
# resource "aws_route_table" "nat-routes" {
#     vpc_id = "${aws_vpc.app_vpc.id}"
#     route {
#         cidr_block = "0.0.0.0/0"
#         nat_gateway_id = "${aws_nat_gateway.web-subnet-nat-gw.id}"
#     }

#     # Attach the propagated routes from the vpn to this route table.
#     propagating_vgws = [
#       "${aws_vpn_gateway.aws-vpn-gw.id}"
#     ]

#     tags {
#         Name = "web-subnet-routes-1"
#     }
# }
# resource "aws_route_table_association" "web-subnet-routes" {
#     subnet_id = "${aws_subnet.wp_subnet.id}"
#     route_table_id = "${aws_route_table.nat-routes.id}"
# }
