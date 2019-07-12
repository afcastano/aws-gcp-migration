output "AWS Bastion public ip" {
  value = "${module.aws_wordpress.wp_eip}"
}

output "AWS WP url" {
  value = "http://wp-demo:8080"
}

output "AWS update local host file" {
  value = "sudo make aws_update_host wpip=${module.aws_wordpress.wp_eip}"
}

output "AWS DB Elastic DNS name" {
  value = "${module.aws_wordpress.db_dns}"
}

output "AWS Connect to bastion instance" {
  value = "sudo chmod 600 terraform/out/aws_key.pem && ssh -i terraform/out/aws_key.pem ubuntu@${module.aws_wordpress.wp_dns}"
}

output "AWS Connect to db instance" {
  value = "sudo chmod 600 terraform/out/aws_key.pem && ssh -i terraform/out/aws_key.pem ubuntu@${module.aws_wordpress.db_dns}"
}

resource "local_file" "aws_key" {
    sensitive_content = "${module.aws_wordpress.instance_key}"
    filename = "${path.module}/out/aws_key.pem"
}

output "Velostrata AWS access key" {
  value = "${module.velostrata.velostrata_aws_key}"
}

output "Velostrata AWS secret key" {
  value = "${module.velostrata.velostrata_aws_secret}"
}

output "gcp bastion public ip" {
  value = "${module.gcp_target.bastion_ip}"
}

output "gcp velostrata manager url" {
  value = "https://${module.velostrata.velostrata_manager_ip}"
}