resource "google_compute_firewall" "firewall_ssh" {
  description = "Allow ssh"
  name        = "default-allow-ssh"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  priority = 65534

  source_ranges = "${var.source_ranges}"
}
