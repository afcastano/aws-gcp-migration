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

For this demo we will install MySql inside an EC2 instance. We could have used RDBS for this, but since the intention of this tutorial is to migrate EC2 instances, then we will do it this way.

The database tier will be a single EC2 instance running MySql service. The constraints are:

- From a networking perspective, every access will be denied except:
    - The word press instances on port 3306. (Default mysql port)
    - The bastion host on port 22 for debugging.
- This EC2 instance would be able to reach internet via NAT.

All other access will be restricted.
```java
//TODO add DB subnet code
```
## Tier 2: Multiple WordPress servers

For this demo we will create two wordpress instances that will use the database defined in the previous tier. We will create a single subnet and for a high availability installation is recommended to put each server in a different availability zone.

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
  depends_on = ["aws_vpc_dhcp_options_association.dns_resolver"]
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
```



