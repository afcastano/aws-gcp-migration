output "AWS wordpress external url" {
  value = "${aws_alb.alb.dns_name}"
}

output "AWS Bastion Elastic DNS name" {
  value = "${aws_eip.bastion_eip.public_dns}"
}

output "AWS Bastion internal ip" {
  value = "${aws_instance.bastion.private_ip}"
}

output "AWS database ip" {
  value = "${aws_db_instance.wpdb.address}"
}

output "AWS wp-server private ips" {
  value = "${zipmap(aws_instance.web-server.*.id, aws_instance.web-server.*.private_ip)}"
}

output "Velostrata AWS access key" {
  value = "${aws_iam_access_key.velostrata-iam-key.id}"
}

output "Velostrata AWS secret key" {
  value = "${aws_iam_access_key.velostrata-iam-key.secret}"
}