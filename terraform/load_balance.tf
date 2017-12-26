resource "google_compute_instance_group" "app" {
  name        = "reddit-app-group"
  description = "Reddit-app LB test"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  named_port {
    name = "app-port"
    port = "9292"
  }

  zone = "${var.zone}"
}

resource "google_compute_global_forwarding_rule" "forward-rule" {
  name       = "default-rule"
  target     = "${google_compute_target_http_proxy.proxy-rule.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "proxy-rule" {
  name        = "test-proxy"
  description = "a description"
  url_map     = "${google_compute_url_map.app-url-map.self_link}"
}

resource "google_compute_url_map" "app-url-map" {
  name            = "url-map"
  description     = "a description"
  default_service = "${google_compute_backend_service.app-backend.self_link}"
}

resource "google_compute_backend_service" "app-backend" {
  name        = "default-backend"
  port_name   = "app-port"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.app.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.app-health-check.self_link}"]
}

resource "google_compute_http_health_check" "app-health-check" {
  name               = "app-health-check"
  request_path       = "/"
  port               = "9292"
  check_interval_sec = 15
  timeout_sec        = 5
}
