# Install WordPress 3-Tier application in AWS using terraform

In this section we will go through the installation of a 3 - Tier wordpress application in aws. We will also set security groups for the instances running on each tier.

The final solution will look like this:

[Insert WP diagram]

Let's go through each of the tiers:
1. VPC and common configuration
2. Tier 3: Restricted access - DB server
3. Tier 2: Restricted access - Multiple WordPress servers
4. Tier 1: Public access - Load balancer and Bastion host

## VPC
First we provision the VPC and define some global resources that will be used by the subnets.

See [vpc.tf](../../../terraform/modules/aws_wordpress/vpc.tf)

```HCL
### AWS VPC ####################################################################
# provision app vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = "${var.aws_network_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "WP Solution VPC"
  }
}

# create igw
resource "aws_internet_gateway" "app_igw" {
  vpc_id = "${aws_vpc.app_vpc.id}"
}

# add dhcp options
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

# associate dhcp with vpc
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.app_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}
```

**aws_vpc.app_vpc:** This resource will be our main vpc and we just configured the cidr range and enabled dns.  

**aws_internet_gateway.app_igw:** Defines an internet gateway to be used by the public subnet and the NAT fo the private subnets.  

**aws_vpc_dhcp_options and aws_vpc_dhcp_options_association:** Defines the DNS server for our VPC. We will use the amazon provided DNS for simplicity but you can add any other DNS ip here. Finaly we associate the DNS configuration with our `app_vpc` resource.  

## Tier 3: DB tier

For this demo we will use RBS as persistence mechanism. This layer actually has two subnets as per RBS requirements.
The network constraints are:
- Allow ingress on port 3306 from WP subnet.
- Allow ingress on port 3306 from Public subnet (this is for bastion host debugging).
- Allow egress to everywhere inside the VPC. (No internet access)
- Deny everything else.

See [db_tier.tf](../../../terraform/modules/aws_wordpress/db_tier.tf)

```HCL
#### DB subnets
resource "aws_subnet" "db_subnet_1" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.aws_db_subnet_1_cidr}"
  tags {
    Name = "WordPress subnet 1"
  }
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.aws_db_subnet_2_cidr}"
  tags {
    Name = "WordPress subnet 2"
  }
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

### SECURITY GROUP 
resource "aws_security_group" "db" {
  name = "db-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # TCP access only from wp subnet and vpn
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [
      "${var.aws_wp_subnet_cidr}", # WP subnet
      "${var.aws_pub_subnet_1_cidr}", # Public subnet for bastion host debug
      "${var.gcp_wp_subnet}" # WP subnet on gcp across the vpn
    ]
  }
  
  # Egress to everyone
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**db_subnet_1 and db_subnet_2:** The two subnets in different availability zones required for RDS. The `availability_zone` attribute is obtained from a `data` resource defined in [main.tf](../../../terraform/modules/aws_wordpress/main.tf), go check it out.

**aws_security_group.db:** The security group for the db. The `ingress` part defines only the port 3306 and the subnet CIDR as explained before. It also includes `var.gcp_wp_subnet` which will be the GCP subnet that will contain the WordPress instances once migrated, as we will explain in the next tutorial.

Creating the RDS instance should be pretty straight forward:
See [db_tier.tf](../../../terraform/modules/aws_wordpress/db_tier.tf)
```HCL
###### provision RDS
# make db subnet group 
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = ["${aws_subnet.db_subnet_1.id}", "${aws_subnet.db_subnet_2.id}"]
}

resource "aws_db_instance" "wp-db" {
  identifier = "wp-db"
  instance_class = "db.t2.micro"
  allocated_storage = 20
  engine = "mysql"
  name = "wordpress_db"
  password = "${var.aws_wp_db_password}"
  username = "${var.aws_wp_db_user}"
  engine_version = "5.7"
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet.name}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
}
```
The `aws_db_subnet_group` is used to indicate the subnets in which we will deploy the DB. Note how we also added the security group we defined earlier to our `aws_db_instance`.


## Tier 2: Multiple WordPress servers

For this demo we will create two wordpress instances that will use the database defined in the previous tier. We will create a single subnet for the demo purposes, however note that for a high availability installation is recommended to put each server in a different subnet.

The wordpress constraints are:
- Allow ssh (http:22) connections from the bastion host in public subnet.
- Allow port http:80 connections from the load balancer in public subnet.
- Instances should be able to reach internet via NAT.

Lets create the wordpress subnet:
See [wp_tier.tf](../../../terraform/modules/aws_wordpress/wp_tier.tf)

```HCL
#provision wordpress subnet
resource "aws_subnet" "wp_subnet" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.aws_wp_subnet_cidr}"
  tags {
    Name = "WordPress subnet"
  }
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

# WP subnet routes for NAT
resource "aws_route_table" "wp-subnet-routes" {
    vpc_id = "${aws_vpc.app_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
    }

    tags {
        Name = "web-subnet-routes-1"
    }
}
resource "aws_route_table_association" "wp-subnet-routes" {
    subnet_id = "${aws_subnet.wp_subnet.id}"
    route_table_id = "${aws_route_table.wp-subnet-routes.id}"
}

### SECURITY GROUPS #########################

#Private access for WP subnet
resource "aws_security_group" "wp" {
  name = "wp-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # ssh access from bastion
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${var.aws_pub_subnet_1_cidr}"]
  }
  
  # http access from load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${var.aws_pub_subnet_1_cidr}"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
**aws_route_table.wp-subnet-routes:** We have to modify the route table of the subnet to add the nat gateway. We then have to use a `aws_route_table_association` to link the route table to the subnet.

**aws_security_group.wp:** Open ingress from the public subnet on ports 22 and 80 for the bastion host and the load balancer respectively. Egress to everyone, even internet via NAT.

Now lets provision our WordPress instances:
See [wp_tier.tf](../../../terraform/modules/aws_wordpress/wp_tier.tf)

```HCL
# WP SERVERS ############################
resource "aws_instance" "wp" {
  ami = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = [
    "${aws_security_group.wp.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.wp_subnet.id}"

  key_name = "${aws_key_pair.demo_keys.key_name}"
  tags {
    Name = "wp-server-${count.index}"
    SELECTOR = "wp"
  }

  count = 2
}

# I would initialize the vm via user_data attribute, but velostrata does not like it.
# https://stackoverflow.com/questions/57016394/velostrata-migration-from-aws-to-gcp-failed-cloud-instance-boot-failed
resource "null_resource" "wp_provisioner" {
  triggers = {
    wp_instace = "${element(aws_instance.wp.*.private_ip, count.index)}"
  }
  provisioner "file" {
    source      = "scripts/init_velostrata.sh"
    destination = "/tmp/init_velostrata.sh"
  }
  provisioner "file" {
    source      = "scripts/init_wp.sh"
    destination = "/tmp/init_wp.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init_velostrata.sh",
      "chmod +x /tmp/init_wp.sh",
      "/tmp/init_velostrata.sh",
      "/tmp/init_wp.sh ${aws_db_instance.wp-db.address} ${var.aws_wp_db_user} ${var.aws_wp_db_password}",
    ]
  }

  connection {
    type                = "ssh"
    private_key         = "${tls_private_key.demo_private_key.private_key_pem}"
    host                = "${element(aws_instance.wp.*.private_ip, count.index)}"
    user                = "ubuntu"
    bastion_host        = "${aws_eip.bastion_eip.public_ip}"
    bastion_private_key = "${tls_private_key.demo_private_key.private_key_pem}"
    bastion_user        = "ubuntu"
    timeout             = "30s"
  }
  depends_on = ["aws_eip_association.bastion_eip_assoc", "aws_instance.wp"]
  count = 2
}
```
**aws_instance.wp:** Our wp instance. The `ami` attribute comes from a `data` resource defined in [main.tf](../../../terraform/modules/aws_wordpress/main.tf), go check it out.  
`key_name` Refers to the key we need to connect to the instance via ssh. That key is also created in [main.tf](../../../terraform/modules/aws_wordpress/main.tf).  
The `count` attribute indicates how many instances of the resource are we creating.

**null_resource.wp_provisioner:** Now, this resource is the one that actually provisions the WordPress software into the instance. There are several aspects worth considering here:
- The `null_resource` doesn't actually creates anything. We use this type of resources for things like this.
- `triggers`: This basically indicates when this resource should be executed. In this case, any time any of the WordPress instance is recreated, we should execute this resource. The trick here is that we assume that if the `private_ip` of an instance changes, it means that it was recreated.
- `provisioner file`: Those are the scripts that will install the software. We have the WordPress server installer and also a Velostrata package that need to be installed for the migration step explained in the next tutorial. Check the scripts out in the [scripts](../../../terraform/scripts) folder.
- `provisioner remote-exec`: Is indicating that terraform should connect to the instance and execute the steps indicated in the `inline` array. Look how we can pass arguments to the script `init_wp.sh`.
- `connection`: Indicates how should we connect to the instance. In this case, we specify that we should go through the bastion host, since the WordPress instances can be accessed from the internet, remember that NAT allows egress only. Also in this block, we specify the `private_key` to use.  
**SECURITY NOTE: This is for demo purposes, it is a bad idea to store secrets in the terraform state!**
- Finally we indicate that this resource should be executed after the external ip of the bastion is assigned, since we need it to reach to the WP instances. Also we create two of this resources.