resource "google_compute_instance_group" "reddit-app" {
  name        = "reddit-app-group"
  description = "Reddit-app LB test"

  instances = [
    "${google_compute_instance.app.*.self_link}"
]

  named_port {
    name = "reddit-port"
    port = "9292"
  }

  zone = "${var.zone}"
}

resource "google_compute_global_forwarding_rule" "reddit-forward" {
  name       = "default-rule"
  target     = "${google_compute_target_http_proxy.reddit-proxy.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "reddit-proxy" {
  name        = "test-proxy"
  description = "a description"
  url_map     = "${google_compute_url_map.reddit-url-map.self_link}"
}

resource "google_compute_url_map" "reddit-url-map" {
  name            = "url-map"
  description     = "a description"
  default_service = "${google_compute_backend_service.reddit-backend.self_link}"
}

resource "google_compute_backend_service" "reddit-backend" {
  name        = "default-backend"
  port_name   = "reddit-port"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.reddit-app.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.reddit-health-check.self_link}"]
}

resource "google_compute_http_health_check" "reddit-health-check" {
  name               = "reddit-health-check"
  request_path       = "/"
  port               = "9292"
  check_interval_sec = 15
  timeout_sec        = 5
}
