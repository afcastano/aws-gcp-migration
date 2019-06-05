/*
 * Terraform compute resources for GCP.
 * Acquire all zones and choose one randomly.
 */

data "google_compute_zones" "available" {
  region = "${var.gcp_region}"
}
