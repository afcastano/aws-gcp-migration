output "vpc_id" {
  value = "${aws_vpc.app_vpc.id}"
}

output "route_table_id" {
  value = "${aws_vpc.app_vpc.default_route_table_id}"
}

output "igw_id" {
  value = "${aws_internet_gateway.app_igw.id}"
}

output "wp_eip" {
    value = "${aws_eip.bastion_eip.public_ip}"
}

output "wp_dns" {
    value = "${aws_eip.bastion_eip.public_dns}"
}

output "db_dns" {
    value = "${aws_eip.db_eip.public_dns}"
}

output "instance_key" {
    value = "${tls_private_key.demo_private_key.private_key_pem}"
}