output "AWS Bastion public ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}

output "Wordpress url" {
  value = "http://wp-demo:8080"
}

output "AWS update local host file" {
  value = "sudo make aws_update_host wpip=${aws_eip.bastion_eip.public_ip}"
}

output "AWS DB Elastic DNS name" {
  value = "${aws_eip.db_eip.public_dns}"
}

output "AWS Bastion internal ip" {
  value = "${aws_instance.bastion.private_ip}"
}

output "AWS DB internal ip" {
  value = "${aws_instance.db.private_ip}"
}

output "AWS Connect to bastion instance" {
  value = "sudo chmod 600 terraform/aws_key.pem && ssh -i terraform/aws_key.pem ubuntu@${aws_eip.bastion_eip.public_dns}"
}

output "AWS Connect to db instance" {
  value = "sudo chmod 600 terraform/aws_key.pem && ssh -i terraform/aws_key.pem ubuntu@${aws_eip.db_eip.public_dns}"
}

resource "local_file" "aws_key" {
    sensitive_content = "${tls_private_key.demo_private_key.private_key_pem}"
    filename = "${path.module}/aws_key.pem"
}

output "Velostrata AWS access key" {
  value = "${aws_iam_access_key.velostrata-iam-key.id}"
}

output "Velostrata AWS secret key" {
  value = "${aws_iam_access_key.velostrata-iam-key.secret}"
}