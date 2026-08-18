# Reads an image that is already on the daemon rather than pulling it here.
# CI pulls the tagged image before running Terraform, which keeps registry
# credentials in the pipeline instead of in Terraform state, and means the
# resolved image ID below changes whenever a new build is pulled — so the
# container is replaced on deploy without needing a tag-change trigger.
data "docker_image" "app" {
  name = var.app_image
}

resource "docker_container" "web" {
  name     = "cinejo-web"
  image    = data.docker_image.app.id
  restart  = "unless-stopped"
  must_run = true

  # No ports block: the container is reachable only through Traefik on the
  # private network, so nothing binds a host port.

  env = [
    "CINEJO_API_BASE_URL=${var.api_base_url}",
    "CINEJO_DEMO_EMAIL=${var.demo_email}",
    "CINEJO_DEMO_PASSWORD=${var.demo_password}",
    "POSTHOG_API_KEY=${var.posthog_api_key}",
    "POSTHOG_HOST=${var.posthog_host}",
  ]

  networks_advanced {
    name = docker_network.cinejo.name
  }

  # Opt this container in to Traefik. Everything else on the daemon stays
  # unpublished because exposedbydefault is off.
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.cinejo.rule"
    value = "Host(`${var.public_domain}`)"
  }

  labels {
    label = "traefik.http.routers.cinejo.entrypoints"
    value = "web"
  }

  # Traefik cannot infer the port: the image exposes both 8080 (app) and
  # 9113 (metrics), and picking the wrong one would route traffic at the
  # stub_status page.
  labels {
    label = "traefik.http.services.cinejo.loadbalancer.server.port"
    value = "8080"
  }

  # Lets Traefik take an unhealthy instance out of rotation rather than
  # serving 502s from a container that is up but not ready.
  labels {
    label = "traefik.http.services.cinejo.loadbalancer.healthcheck.path"
    value = "/healthz"
  }

  labels {
    label = "traefik.http.services.cinejo.loadbalancer.healthcheck.interval"
    value = "30s"
  }

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
  name     = "cinejo-web-metrics"
  image    = docker_image.nginx_exporter.image_id
  restart  = "unless-stopped"
  must_run = true

  command = [
    "--nginx.scrape-uri=http://${docker_container.web.name}:9113/stub_status",
  ]

  # Published so Prometheus can scrape it from elsewhere on the homelab.
  # Not routed through Traefik: metrics should not be reachable from the
  # public entrypoint.
  ports {
    internal = 9113
    external = var.metrics_port
  }

  networks_advanced {
    name = docker_network.cinejo.name
  }

  security_opts = ["no-new-privileges:true"]
}
