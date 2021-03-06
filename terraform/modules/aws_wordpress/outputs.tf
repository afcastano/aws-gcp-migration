output "vpc_id" {
  value = "${aws_vpc.app_vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.wp_subnet.id}"
}

output "availability_zone" {
  value = "${data.aws_availability_zones.available.names[0]}"
}

output "security_group_id" {
  value = "${aws_security_group.wp.id}"
}

output "wp_route_table_id" {
  value = "${aws_route_table.wp-subnet-routes.id}"
}

output "db_route_table_id" {
  value = "${aws_route_table.db-subnet-routes.id}"
}

output "bastion_eip" {
    value = "${aws_eip.bastion_eip.public_ip}"
}

output "db_ip" {
    value = "${aws_db_instance.wp-db.address}"
}

output "wp_ip" {
  value = "${aws_instance.wp.*.private_ip}"
}

output "wp_dns" {
  value = "${aws_alb.alb.dns_name}"
}

output "instance_key" {
    value = "${tls_private_key.demo_private_key.private_key_pem}"
}