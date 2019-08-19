#####
# Based on https://cloud.google.com/velostrata/docs/how-to/configuring-gcp/configuring-gcp-manually
####

# ========================================================================================
# Required apis for velostrata
resource "google_project_service" "velostrata-services-iam" {
  project = "${var.gcp_projectId}"
  service = "iam.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "velostrata-services-cloudresourcemanager" {
  project = "${var.gcp_projectId}"
  service = "cloudresourcemanager.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "velostrata-services-storage" {
  project = "${var.gcp_projectId}"
  service = "storage-component.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "velostrata-services-logging" {
  project = "${var.gcp_projectId}"
  service = "logging.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "velostrata-services-monitoring" {
  project = "${var.gcp_projectId}"
  service = "monitoring.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

# ========================================================================================
# Required roles for velostrata
resource "google_project_iam_custom_role" "velos_manager" {
  role_id     = "velos_manager"
  title       = "Velostrata Manager"
  description = "Velostrata Manager"
  permissions = [
    "compute.addresses.create",
    "compute.addresses.createInternal",
    "compute.addresses.delete",
    "compute.addresses.deleteInternal",
    "compute.addresses.get",
    "compute.addresses.list",
    "compute.addresses.setLabels",
    "compute.addresses.use",
    "compute.addresses.useInternal",
    "compute.diskTypes.get",
    "compute.diskTypes.list",
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.get",
    "compute.disks.list",
    "compute.disks.setLabels",
    "compute.disks.update",
    "compute.disks.use",
    "compute.disks.useReadOnly",
    "compute.images.get",
    "compute.images.list",
    "compute.images.useReadOnly",
    "compute.instances.attachDisk",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.detachDisk",
    "compute.instances.get",
    "compute.instances.getSerialPortOutput",
    "compute.instances.list",
    "compute.instances.reset",
    "compute.instances.setDiskAutoDelete",
    "compute.instances.setLabels",
    "compute.instances.setMachineType",
    "compute.instances.setMetadata",
    "compute.instances.setMinCpuPlatform",
    "compute.instances.setScheduling",
    "compute.instances.setServiceAccount",
    "compute.instances.setTags",
    "compute.instances.start",
    "compute.instances.startWithEncryptionKey",
    "compute.instances.stop",
    "compute.instances.update",
    "compute.instances.updateNetworkInterface",
    "compute.instances.use",
    "compute.licenseCodes.get",
    "compute.licenseCodes.list",
    "compute.licenseCodes.update",
    "compute.licenseCodes.use",
    "compute.licenses.get",
    "compute.licenses.list",
    "compute.machineTypes.get",
    "compute.machineTypes.list",
    "compute.networks.get",
    "compute.networks.list",
    "compute.networks.use",
    "compute.networks.useExternalIp",
    "compute.nodeTemplates.list",
    "compute.projects.get",
    "compute.regionOperations.get",
    "compute.regions.get",
    "compute.regions.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.zoneOperations.get",
    "compute.zones.get",
    "compute.zones.list",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "resourcemanager.projects.get",
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.update",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.update"
  ]
}

resource "google_project_iam_custom_role" "velos_ce" {
  role_id     = "velos_ce"
  title       = "Velostrata Cloud Extensions"
  description = "Velostrata Cloud Extensions"
  permissions = [
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.update"
  ]
}

# ========================================================================================
# Service account for velostrata manager and cloud extensions

resource "google_service_account" "velos-manager" {
  account_id   = "velos-manager"
  display_name = "velos-manager"
}

resource "google_service_account" "velos-cloud-extension" {
  account_id   = "velos-cloud-extension"
  display_name = "velos-cloud-extension"
}

# ========================================================================================
# Service account for velostrata workload
resource "google_service_account" "velos-workload" {
  account_id   = "velos-workload"
  display_name = "velos-workload"
}

# ========================================================================================
# Role bindings for service accounts

resource "google_project_iam_member" "velos-workload-binding" {
  project = "${var.gcp_projectId}"
  role    = "roles/editor"

  member = "serviceAccount:${google_service_account.velos-workload.email}"
}

resource "google_project_iam_member" "velos-extension-binding" {
  project = "${var.gcp_projectId}"
  role    = "projects/${var.gcp_projectId}/roles/${google_project_iam_custom_role.velos_ce.role_id}"

  member = "serviceAccount:${google_service_account.velos-cloud-extension.email}"
}

resource "google_project_iam_member" "velos-manager-binding" {
  project = "${var.gcp_projectId}"
  role    = "projects/${var.gcp_projectId}/roles/${google_project_iam_custom_role.velos_manager.role_id}"

  member = "serviceAccount:${google_service_account.velos-manager.email}"
}

resource "google_project_iam_member" "serviceAccount-binding" {
  project = "${var.gcp_projectId}"
  role    = "roles/iam.serviceAccountUser"

  member = "serviceAccount:${google_service_account.velos-manager.email}"
}

resource "google_project_iam_member" "serviceAccount-logging" {
  project = "${var.gcp_projectId}"
  role    = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.velos-manager.email}"
}

resource "google_project_iam_member" "velos-extension-logging" {
  project = "${var.gcp_projectId}"
  role    = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.velos-cloud-extension.email}"
}

resource "google_project_iam_member" "serviceAccount-metrics" {
  project = "${var.gcp_projectId}"
  role    = "roles/monitoring.metricWriter"

  member = "serviceAccount:${google_service_account.velos-manager.email}"
}

resource "google_project_iam_member" "velos-extension-metrics" {
  project = "${var.gcp_projectId}"
  role    = "roles/monitoring.metricWriter"

  member = "serviceAccount:${google_service_account.velos-cloud-extension.email}"
}

resource "google_project_iam_member" "serviceAccount-monitoring" {
  project = "${var.gcp_projectId}"
  role    = "roles/monitoring.viewer"

  member = "serviceAccount:${google_service_account.velos-manager.email}"
}

resource "google_project_iam_member" "serviceAccount-token-creator" {
  project = "${var.gcp_projectId}"
  role    = "roles/iam.serviceAccountTokenCreator"

  member = "serviceAccount:${google_service_account.velos-manager.email}"
}

# ========================================================================================
# Compute instance to host Velostrata manager.
# Should be in the public network.
# Ref: https://cloud.google.com/velostrata/docs/how-to/configure-manager/configuring-on-gcp

resource "google_compute_instance" "velostrata-manager" {
  name         = "velostrata-manager"
  machine_type = "${var.gcp_instance_type}"
  zone         = "${var.gcp_zone}"

  boot_disk {
    initialize_params {
      image = "${var.velostrata_manager_img}"
      size  = 60
    }
  }

  service_account {
    email  = "${google_service_account.velos-manager.email}"
    scopes = [ "https://www.googleapis.com/auth/cloud-platform", "rpc://phrixus.googleapis.com/auth/cloudrpc" ]
  }

  network_interface {
    subnetwork = "${var.gcp_velos_manager_subnet}"

    access_config {
    }
  }

  tags = ["${var.gcp_velostrata_manager_tag}"]

  metadata = {
    apiPassword              = "${var.gcp_velostrata_api_password}"
    secretsEncKey            = "${var.gcp_velostrata_enc_key}"
    defaultServiceAccount    = "${google_service_account.velos-cloud-extension.email}"
    google-monitoring-enable = "1"
    google-logging-enable    = "1"
  }
}

# Velostrata firewall rules
# Ref: https://cloud.google.com/velostrata/docs/concepts/planning-a-migration/network-access-requirements


# Allow access from internet to velostrata manager.
resource "google_compute_firewall" "gcp-velostrata-manager-ingress-https-grpc" {
  name    = "${var.gcp_vpc_name}-gcp-velostrata-manager-ingress-https-grpc"
  network = "${var.gcp_vpc_name}"


  allow {
    protocol = "all"
  }

  target_tags = [
    "${var.gcp_velostrata_manager_tag}"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "gcp-velos-ce-control" {
  name    = "${var.gcp_vpc_name}-gcp-velos-ce-control"
  network = "${var.gcp_vpc_name}"


  allow {
    protocol = "all"
  }

  target_tags = [
    "${var.gcp_velostrata_extension_tag}"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Allow access to workload instances from public internet.
resource "google_compute_firewall" "gcp-workload-ingress-ssh-public" {
  name    = "${var.gcp_vpc_name}-gcp-workload-ingress-ssh-public"
  network = "${var.gcp_vpc_name}"

  allow {
    protocol = "all"
  }

  target_tags = [
    "${var.gcp_velostrata_workload_tag}"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

