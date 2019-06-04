resource "aws_cloudformation_stack" "velostrata-iam" {
    name = "velostrata-iam"
    
    capabilities = ["CAPABILITY_IAM"]
    
    parameters = {
        VPC = "${aws_vpc.app_vpc.id}"
    }

    template_body = <<STACK
    ${file("aws_cloudconfig/velostrata_cloudformation.json")}
    STACK
}