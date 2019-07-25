/*
 * Terraform security (firewall) resources for GCP.
 */


# Allow PING testing and ssh to the bastion instances.
resource "google_compute_firewall" "gcp-bastion-all" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-public-ingress-icmp-ssh"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "all"
  }

  target_tags = [
    "bastion",
    "wp"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}




# # Allow communication to wp instances from a restricted set of tags.
# resource "google_compute_firewall" "wp-from-bastion-lb" {
#   name    = "${google_compute_network.demo-vpc.name}-wp-from-bastion-lb"
#   network = "${google_compute_network.demo-vpc.name}"


#   allow {
#     protocol = "all"
#   }

#   target_tags = [
#     "wp"
#   ]

#   source_tags = [
#     "bastion"
#   ]
# }


# # Default rules to deny any ingress or egress
# resource "google_compute_firewall" "deny-all-ingress" {
#   name    = "${google_compute_network.demo-vpc.name}-deny-all-ingress"
#   network = "${google_compute_network.demo-vpc.name}"

#   priority = "9999"

#   deny {
#     protocol = "all"
#   }  

#   source_ranges = [
#     "0.0.0.0/0"
#   ]

# }

# resource "google_compute_firewall" "deny-all-egress" {
#   name    = "${google_compute_network.demo-vpc.name}-deny-all-ingress"
#   network = "${google_compute_network.demo-vpc.name}"

#   priority = "9999"

#   deny {
#     protocol = "all"
#   }  

#   destination_ranges = [
#     "0.0.0.0/0"
#   ]

# }