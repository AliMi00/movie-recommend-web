# Public image, so Terraform pulls it directly — no registry credentials
# involved. (The app image is handled differently in app.tf: it lives in
# GHCR behind auth that belongs in CI, not in Terraform state.)
# keep_locally stops `terraform destroy` from evicting a shared base image
# that other stacks on this host may also be using.
resource "docker_image" "traefik" {
  name         = "traefik:v3.2"
  keep_locally = true
}

# Routing table for Traefik, delivered as a file rather than discovered from
# Docker labels. Two reasons, in order of importance:
#
#   1. The Docker provider requires mounting the daemon socket into the edge
#      proxy. That socket is root-equivalent on the host, so it turns any
#      Traefik RCE into a full host compromise. This stack has exactly one
#      backend whose address is already known at plan time, so label-based
#      discovery buys nothing that justifies that exposure.
#   2. Traefik's Docker provider negotiates API version 1.24, which daemons
#      from Docker 25 onward reject (they require >= 1.40). Setting
#      DOCKER_API_VERSION does not override it, so on a current daemon the
#      provider never connects and every route 404s.
#
# Traefik reaches the backend by container name over the shared bridge,
# resolved by Docker's embedded DNS.
locals {
  traefik_dynamic_config = yamlencode({
    http = {
      routers = {
        cinejo = {
          rule        = "Host(`${var.public_domain}`)"
          entryPoints = ["web"]
          service     = "cinejo"
        }
      }
      services = {
        cinejo = {
          loadBalancer = {
            servers = [{ url = "http://${docker_container.web.name}:8080" }]
            # Takes the backend out of rotation when it stops serving,
            # so a broken rollout returns 503 rather than a blank page.
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

# Edge router for the stack. TLS is deliberately NOT handled here: the VPS
# in front already terminates HTTPS and forwards over Tailscale, so a second
# certificate would be redundant and would need the homelab reachable from
# the public internet. Traefik's job here is routing and the request/latency
# metrics the nginx stub_status page cannot provide.
resource "docker_container" "traefik" {
  name     = "cinejo-traefik"
  image    = docker_image.traefik.image_id
  restart  = "unless-stopped"
  must_run = true

  command = [
    "--providers.file.directory=/etc/traefik/dynamic",
    "--providers.file.watch=true",
    "--entrypoints.web.address=:80",
    # Metrics ride a separate entrypoint so they are never routable from
    # the public entrypoint.
    "--entrypoints.metrics.address=:8082",
    "--metrics.prometheus=true",
    "--metrics.prometheus.entrypoint=metrics",
    # Per-router latency histograms; without this only counters are emitted.
    "--metrics.prometheus.addrouterslabels=true",
    "--accesslog=true",
    "--accesslog.format=json",
    "--log.level=INFO",
    "--ping=true",
    "--ping.entrypoint=metrics",
  ]

  # Written into the container at create time, so there is no host bind
  # mount to provision separately and the routing table is versioned here
  # with the rest of the infrastructure.
  upload {
    file    = "/etc/traefik/dynamic/cinejo.yml"
    content = local.traefik_dynamic_config
  }

  ports {
    internal = 80
    external = var.http_port
  }

  ports {
    internal = 8082
    external = var.traefik_metrics_port
  }

  networks_advanced {
    name = docker_network.cinejo.name
  }

  healthcheck {
    test     = ["CMD", "traefik", "healthcheck", "--ping", "--ping.entrypoint=metrics"]
    interval = "30s"
    timeout  = "5s"
    retries  = 3
  }

  security_opts = ["no-new-privileges:true"]
}
