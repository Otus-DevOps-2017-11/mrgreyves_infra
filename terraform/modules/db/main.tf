data "template_file" "mongod-config" {
  template = "${file("${path.module}/files/mongo.conf.tpl")}"

  vars {
    mongo_address = "0.0.0.0"
  }
}

resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    private_key = "${file(var.private_key_path)}"
  }

//  provisioner "file" {
//    content     = "${data.template_file.mongod-config.rendered}"
//    destination = "/tmp/mongod.conf"
//  }

//  provisioner "remote-exec" {
//    inline = [
//      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
//      "sudo systemctl restart mongod",
//    ]
//  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]

  source_tags = ["reddit-app"]
}
