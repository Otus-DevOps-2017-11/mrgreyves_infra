variable public_key_path {
  description = "~/.ssh/appuser.pub"
}

variable private_key_path {
  description = "~/.ssh/appuser"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable machine_type {
  default = "g1-small"
}

variable db_address {
  default = "127.0.0.1"
}
