output "1 Configure Wordpress in aws" {
  value = "make wp_aws"
}

output "2 Accept eula" {
  value = "make eula"
}

output "3 Run migration" {
  value = "make velostrata_migrate"
}

output "4 Check out WordPres in google" {
  value = "make wp_gcp"
}
output "5 (INFO) Internal ips" {
  value = <<EOF

  Connect to bastion: sudo chmod 600 terraform/out/aws_key.pem && ssh -i terraform/out/aws_key.pem ubuntu@${module.aws_wordpress.bastion_eip}
  
  AWS private ips:
  WP servers ip: [${join(", ", module.aws_wordpress.wp_ip)}]
  DB instance ip: ${module.aws_wordpress.db_ip}

  Gcp bastion public ip: ${module.gcp_target.bastion_ip}
  Gcp velostrata manager url: https://${module.velostrata.velostrata_manager_ip}
  EOF
}

resource "local_file" "aws_key" {
    sensitive_content = "${module.aws_wordpress.instance_key}"
    filename = "${path.module}/out/aws_key.pem"
}

resource "local_file" "velostrata_variables" {
  content = <<EOF
  export aws_subnet=${module.aws_wordpress.subnet_id}
  export aws_availability_zone=${module.aws_wordpress.availability_zone}
  export aws_region=${var.aws_region}
  export security_group=${module.aws_wordpress.security_group_id}
  export aws_key=${module.velostrata.velostrata_aws_key}
  export aws_secret=${module.velostrata.velostrata_aws_secret}
  export gcp_workload_subnet_id=${module.gcp_target.wp_subnet_id}
  export ce_subnet_id=${module.gcp_target.public_subnet_id}
  export gcp_region=${var.gcp_region}
  export gcp_project_id=${var.gcp_projectId}
  export velostrata_ip=${module.velostrata.velostrata_manager_ip}
  export wp_aws_dns=${module.aws_wordpress.wp_dns}
  export wp_gcp_ip=${module.gcp_target.wp_ip}
  EOF
  filename = "${path.module}/out/velostrata.env"
}