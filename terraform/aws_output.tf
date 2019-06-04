output "AWS wordpress external url" {
  value = "${aws_alb.alb.dns_name}"
}

output "AWS Bastion Elastic DNS name" {
  value = "${aws_eip.bastion_eip.public_dns}"
}

output "AWS wp-server private ips" {
  value = "${zipmap(aws_instance.web-server.*.id, aws_instance.web-server.*.private_ip)}"
}

output "Velostrata key id" {
  value = "${aws_iam_access_key.velostrata-iam-key.id}"
}

output "Velostrata key secret" {
  value = "${aws_iam_access_key.velostrata-iam-key.secret}"
}