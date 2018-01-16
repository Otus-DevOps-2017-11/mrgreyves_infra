variable project {
  description = "aerial-yeti-188613"
}

variable public_key_path {
  description = "~/.ssh/appuser.pub"
}

variable disk_image {
  description = "reddit-base"
}

variable private_key_path {
  description = "~/.ssh/appuser"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Application zone"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
