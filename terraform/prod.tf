# Production deployment: app.cinreco.com. Reuses the same app image and the
# same bridge network as the demo (web/traefik/metrics in app.tf/traefik.tf),
# but is otherwise a second, fully independent stack — its own container,
# its own Traefik, its own ports. No resource here references or modifies
# docker_container.web / .traefik / .metrics, so applying this cannot
# recreate or disturb the live demo, regardless of what state those
# resources are in.
#
# No demo login: CINRECO_DEMO_EMAIL/PASSWORD are hardcoded empty (not wired
# to any variable) so a production deployment can never accidentally ship
# the shared demo account. CINRECO_SHOW_DEMO_BANNER=false hides the
# "Portfolio Demo Project" banner that ships on by default for every other
# deployment (see app_config.dart).
resource "docker_container" "web_prod" {
  name     = "cinreco-app-prod"
  image    = data.docker_image.app.id
  restart  = "unless-stopped"
  must_run = true

  env = [
    "CINRECO_API_BASE_URL=${var.prod_api_base_url}",
    "CINRECO_DEMO_EMAIL=",
    "CINRECO_DEMO_PASSWORD=",
    "CINRECO_SHOW_DEMO_BANNER=false",
    "POSTHOG_API_KEY=${var.prod_posthog_api_key}",
    "POSTHOG_HOST=${var.prod_posthog_host}",
  ]

  networks_advanced {
    name = docker_network.cinreco.name
  }

  # No Traefik labels: routing is declared in the file provider config
  # below, for the same reason as the demo stack (traefik.tf) — no Docker
  # socket in the edge proxy.

  healthcheck {
    test     = ["CMD", "curl", "-fsS", "http://localhost:8080/healthz"]
    interval = "30s"
    timeout  = "3s"
    retries  = 3
  }

  security_opts = ["no-new-privileges:true"]
}

resource "docker_container" "metrics_prod" {
  name     = "cinreco-app-prod-metrics"
  image    = docker_image.nginx_exporter.image_id
  restart  = "unless-stopped"
  must_run = true

  command = [
    "--nginx.scrape-uri=http://${docker_container.web_prod.name}:9113/stub_status",
  ]

  # Not routed through Traefik: metrics should not be reachable from the
  # public entrypoint.
  ports {
    internal = 9113
    external = var.prod_metrics_port
  }

  networks_advanced {
    name = docker_network.cinreco.name
  }

  security_opts = ["no-new-privileges:true"]
}

# Own Traefik instance rather than a second router bolted onto the demo's
# (docker_container.traefik in traefik.tf): that container's routing table
# is delivered via an `upload` block, and changing an upload's content
# forces the container to be replaced — which would restart the demo's
# Traefik (and briefly interrupt demo1.mobini.nl) just to add a route that
# has nothing to do with it. Reuses docker_image.traefik (same image,
# already pulled) rather than pulling it again.
locals {
  traefik_prod_dynamic_config = yamlencode({
    http = {
      routers = {
        cinreco-prod = {
          rule        = "Host(`${var.prod_domain}`)"
          entryPoints = ["web"]
          service     = "cinreco-prod"
        }
      }
      services = {
        cinreco-prod = {
          loadBalancer = {
            servers = [{ url = "http://${docker_container.web_prod.name}:8080" }]
            healthCheck = {
              path     = "/healthz"
              interval = "30s"
              timeout  = "3s"
            }
          }
        }
      }
    }
  })
}

resource "docker_container" "traefik_prod" {
  name     = "cinreco-prod-traefik"
  image    = docker_image.traefik.image_id
  restart  = "unless-stopped"
  must_run = true

  command = [
    "--providers.file.directory=/etc/traefik/dynamic",
    "--providers.file.watch=true",
    "--entrypoints.web.address=:80",
    "--entrypoints.metrics.address=:8082",
    "--metrics.prometheus=true",
    "--metrics.prometheus.entrypoint=metrics",
    "--metrics.prometheus.addrouterslabels=true",
    "--accesslog=true",
    "--accesslog.format=json",
    "--log.level=INFO",
    "--ping=true",
    "--ping.entrypoint=metrics",
  ]

  upload {
    file    = "/etc/traefik/dynamic/cinreco.yml"
    content = local.traefik_prod_dynamic_config
  }

  ports {
    internal = 80
    external = var.prod_http_port
    ip       = var.prod_traefik_bind_ip
  }

  ports {
    internal = 8082
    external = var.prod_traefik_metrics_port
  }

  networks_advanced {
    name = docker_network.cinreco.name
  }

  healthcheck {
    test     = ["CMD", "wget", "-q", "-O", "/dev/null", "http://localhost:8082/ping"]
    interval = "30s"
    timeout  = "5s"
    retries  = 3
  }

  security_opts = ["no-new-privileges:true"]
}

output "prod_public_url" {
  description = "URL the production app is served on, via the upstream reverse proxy (once Caddy has a site block for it)."
  value       = "https://${var.prod_domain}"
}

output "prod_traefik_entrypoint" {
  description = "Host port the upstream reverse proxy should forward app.cinreco.com to."
  value       = var.prod_http_port
}

output "prod_nginx_metrics_endpoint" {
  description = "Prometheus scrape target for the production app's nginx connection/request metrics."
  value       = "http://<this-host>:${var.prod_metrics_port}/metrics"
}

output "prod_traefik_metrics_endpoint" {
  description = "Prometheus scrape target for the production Traefik's request rate and latency."
  value       = "http://<this-host>:${var.prod_traefik_metrics_port}/metrics"
}
