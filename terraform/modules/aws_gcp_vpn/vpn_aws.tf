## AWS VPN CONNECTION ##############################################
resource "aws_vpn_gateway" "aws-vpn-gw" {
  vpc_id = "${var.aws_vpc_id}"
}

resource "aws_customer_gateway" "aws-cgw" {
  bgp_asn    = 65000
  ip_address = "${google_compute_address.gcp-vpn-ip.address}"
  type       = "ipsec.1"
  tags {
    "Name" = "aws-customer-gw"
  }
}

resource "aws_vpn_gateway_route_propagation" "wp-gcp-vpc" {
  vpn_gateway_id = "${aws_vpn_gateway.aws-vpn-gw.id}"
  route_table_id = "${var.wp_route_table_id}"
}

resource "aws_vpn_gateway_route_propagation" "db-gcp-vpc" {
  vpn_gateway_id = "${aws_vpn_gateway.aws-vpn-gw.id}"
  route_table_id = "${var.db_route_table_id}"
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