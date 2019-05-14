region = "ap-southeast-2"
availability_zone_1 = "ap-southeast-2a"
availability_zone_2 = "ap-southeast-2b"
db_user = "admin"
db_password = "Stratoscale!Orchestration!"
# Number of web servers (Load balancer will automatically manage target groups)
web_number = "2"

# Use Public Xenial cloud image ami
# Recommend use of Xenial's latest cloud image
# located here: https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
web_ami = "ami-05f29a2b825ca5210"
web_instance_type = "t2.medium"
public_key_path = "./ssh_public_key/aws_wp_id_rsa.pub"
public_key_name = "wp_demo"