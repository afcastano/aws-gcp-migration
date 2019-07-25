output "AWS-1 update local host file" {
  value = <<EOF

  make update_host wp_dns=${module.aws_wordpress.wp_eip}
  EOF
}

output "AWS-2 WP url" {
  value = "make open_demo"
}

output "AWS-3 Connect to bastion instance" {
  value = <<EOF

  sudo chmod 600 terraform/out/aws_key.pem && ssh -i terraform/out/aws_key.pem ubuntu@${module.aws_wordpress.bastion_eip}
  EOF
}

output "AWS-4 Internal ips" {
  value = <<EOF

  SSH to bastion and then, using same credentials go to:
  WP servers ip: [${join(", ", module.aws_wordpress.wp_ip)}]
  DB instance ip: ${module.aws_wordpress.db_ip}
  EOF
}

resource "local_file" "aws_key" {
    sensitive_content = "${module.aws_wordpress.instance_key}"
    filename = "${path.module}/out/aws_key.pem"
}

# resource "local_file" "velostrata_variables" {
#   content = <<EOF
#   export aws_subnet=${module.aws_wordpress.subnet_id}
#   export aws_availability_zone=${var.aws_availability_zone}
#   export aws_region=${var.aws_region}
#   export security_group=${module.aws_wordpress.security_group_id}
#   export aws_key=${module.velostrata.velostrata_aws_key}
#   export aws_secret=${module.velostrata.velostrata_aws_secret}
#   export gcp_workload_subnet_id=${module.gcp_target.public_subnet_id}
#   export gcp_region=${var.gcp_region}
#   export gcp_project_id=${var.gcp_projectId}
#   export velostrata_ip=${module.velostrata.velostrata_manager_ip}
#   export wpip=${module.aws_wordpress.wp_eip}
#   EOF
#   filename = "${path.module}/out/velostrata.env"
# }

# output "Velostrata AWS access key" {
#   value = "${module.velostrata.velostrata_aws_key}"
# }

# output "Velostrata AWS secret key" {
#   value = "${module.velostrata.velostrata_aws_secret}"
# }

# output "gcp bastion public ip" {
#   value = "${module.gcp_target.bastion_ip}"
# }

# output "gcp velostrata manager url" {
#   value = "https://${module.velostrata.velostrata_manager_ip}"
# }