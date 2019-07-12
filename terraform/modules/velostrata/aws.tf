resource "aws_cloudformation_stack" "velostrata-iam-group" {
    name = "velostrata-iam"
    
    capabilities = ["CAPABILITY_IAM"]
    
    parameters = {
        VPC = "${var.aws_vpc_id}"
    }

    template_body = <<STACK
    ${file("./modules/velostrata/velostrata_cloudformation.json")}
    STACK
}

resource "aws_iam_user" "velostrata-iam-user" {
  name = "velostrata-user"
}

resource "aws_iam_access_key" "velostrata-iam-key" {
  user    = "${aws_iam_user.velostrata-iam-user.name}"
}

resource "aws_iam_group_membership" "velostrata-iam-membership" {
  name = "velostrata-iam-membership"

  users = [
    "${aws_iam_user.velostrata-iam-user.name}"
  ]

  group = "${aws_cloudformation_stack.velostrata-iam-group.outputs["iamGroup"]}"
}