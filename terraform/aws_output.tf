output "AWS Bastion public ip" {
  value = "${module.aws_wordpress.wp_eip}"
}

output "Wordpress url" {
  value = "http://wp-demo:8080"
}

output "AWS update local host file" {
  value = "sudo make aws_update_host wpip=${module.aws_wordpress.wp_eip}"
}

output "AWS DB Elastic DNS name" {
  value = "${module.aws_wordpress.db_dns}"
}

# output "AWS Bastion internal ip" {
#   value = "${aws_instance.bastion.private_ip}"
# }

# output "AWS DB internal ip" {
#   value = "${aws_instance.db.private_ip}"
# }

output "AWS Connect to bastion instance" {
  value = "sudo chmod 600 terraform/aws_key.pem && ssh -i terraform/aws_key.pem ubuntu@${module.aws_wordpress.wp_dns}"
}

output "AWS Connect to db instance" {
  value = "sudo chmod 600 terraform/aws_key.pem && ssh -i terraform/aws_key.pem ubuntu@${module.aws_wordpress.db_dns}"
}

resource "local_file" "aws_key" {
    sensitive_content = "${module.aws_wordpress.instance_key}"
    filename = "${path.module}/aws_key.pem"
}

output "Velostrata AWS access key" {
  value = "${aws_iam_access_key.velostrata-iam-key.id}"
}

output "Velostrata AWS secret key" {
  value = "${aws_iam_access_key.velostrata-iam-key.secret}"
}