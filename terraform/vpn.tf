## VPN CONNECTION ##############################################
resource "aws_vpn_gateway" "aws-vpn-gw" {
  vpc_id = "${module.aws_wordpress.vpc_id}"
}

resource "aws_customer_gateway" "aws-cgw" {
  bgp_asn    = 65000
  ip_address = "${google_compute_address.gcp-vpn-ip.address}"
  type       = "ipsec.1"
  tags {
    "Name" = "aws-customer-gw"
  }
}

resource "aws_default_route_table" "aws-vpc" {
  default_route_table_id = "${module.aws_wordpress.route_table_id}"
  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id = "${module.aws_wordpress.igw_id}"
  }
  propagating_vgws = [
    "${aws_vpn_gateway.aws-vpn-gw.id}"
  ]
}

resource "aws_vpn_connection" "aws-vpn-connection1" {
  vpn_gateway_id      = "${aws_vpn_gateway.aws-vpn-gw.id}"
  customer_gateway_id = "${aws_customer_gateway.aws-cgw.id}"
  type                = "ipsec.1"
  static_routes_only  = false
  tags {
    "Name" = "aws-vpn-connection1"
  }
}