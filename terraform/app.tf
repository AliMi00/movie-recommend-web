# Reads an image that is already on the daemon rather than pulling it here.
# CI pulls the tagged image before running Terraform, which keeps registry
# credentials in the pipeline instead of in Terraform state, and means the
# resolved image ID below changes whenever a new build is pulled — so the
# container is replaced on deploy without needing a tag-change trigger.
data "docker_image" "app" {
  name = var.app_image
}

resource "docker_container" "web" {
  name     = "cinreco-web"
  image    = data.docker_image.app.id
  restart  = "unless-stopped"
  must_run = true

  # No ports block: the container is reachable only through Traefik on the
  # private network, so nothing binds a host port.

  env = [
    "CINRECO_API_BASE_URL=${var.api_base_url}",
    "CINRECO_DEMO_EMAIL=${var.demo_email}",
    "CINRECO_DEMO_PASSWORD=${var.demo_password}",
    "POSTHOG_API_KEY=${var.posthog_api_key}",
    "POSTHOG_HOST=${var.posthog_host}",
  ]

  networks_advanced {
    name = docker_network.cinreco.name
  }

  # No Traefik labels here: routing is declared in the file provider config
  # in traefik.tf, which avoids mounting the Docker socket into the proxy.

  healthcheck {
    test     = ["CMD", "curl", "-fsS", "http://localhost:8080/healthz"]
    interval = "30s"
    timeout  = "3s"
    retries  = 3
  }

  # A container breakout should not be able to acquire new privileges.
  security_opts = ["no-new-privileges:true"]
}

# Turns nginx's stub_status page into Prometheus metrics. Runs as a sidecar
# so the app image stays a stock nginx rather than one rebuilt with a
# third-party metrics module.
resource "docker_image" "nginx_exporter" {
  name         = "nginx/nginx-prometheus-exporter:1.3.0"
  keep_locally = true
}

resource "docker_container" "metrics" {
  name     = "cinreco-web-metrics"
  image    = docker_image.nginx_exporter.image_id
  restart  = "unless-stopped"
  must_run = true

  command = [
    "--nginx.scrape-uri=http://${docker_container.web.name}:9113/stub_status",
  ]

  # Published so Prometheus can scrape it from elsewhere on this host or tailnet.
  # Not routed through Traefik: metrics should not be reachable from the
  # public entrypoint.
  ports {
    internal = 9113
    external = var.metrics_port
  }

  networks_advanced {
    name = docker_network.cinreco.name
  }

  security_opts = ["no-new-privileges:true"]
}
