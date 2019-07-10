output "vpc_name" {
    value = "${google_compute_network.demo-vpc.name}"
}

output "bastion_ip" {
    value = "${google_compute_instance.gcp-bastion.network_interface.0.access_config.0.nat_ip}"    
}

output "public_subnet_name" {
    value = "${google_compute_subnetwork.public-subnet.name}"
}