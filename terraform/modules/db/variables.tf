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

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable machine_type {
  default = "g1-small"
}

variable mongo_address {
  default = "0.0.0.0"
}
