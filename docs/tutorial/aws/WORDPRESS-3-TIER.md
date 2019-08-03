# Install WordPress 3-Tier application in AWS using terraform

In this section we will go through the installation of a 3 - Tier wordpress application in aws. We will also set security groups for the instances running on each tier.

The final solution will look like this:

[Insert WP diagram]

Let's go through each of the tiers:
- Tier 1: Public access - Load balancer and Bastion host
- Tier 2: Private access - Multiple WordPress servers
- Tier 3: Private access - DB server

Lets start from the bottom.

## Tier 3: DB tier

For this demo we will install MySql inside an EC2 instance. We could have used RDBS for this, but since the intention of this tutorial is to migrate EC2 instances, then we will do it this way.

The database tier will be a single EC2 instance running MySql service. The constraints are:

- From a networking perspective, every access will be denied except:
    - The word press instances on port 3306. (Default mysql port)
    - The bastion host on port 22 for debugging.
- This EC2 instance would be able to reach internet via NAT.

All other access will be restricted.