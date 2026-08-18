# Public image, so Terraform pulls it directly — no registry credentials
# involved. (The app image is handled differently in app.tf: it lives in
# GHCR behind auth that belongs in CI, not in Terraform state.)
# keep_locally stops `terraform destroy` from evicting a shared base image
# that other stacks on this host may also be using.
resource "docker_image" "traefik" {
  name         = "traefik:v3.2"
  keep_locally = true
}

# Edge router for the stack. TLS is deliberately NOT handled here: the VPS
# in front already terminates HTTPS and forwards over Tailscale, so a second
# certificate would be redundant and would need the homelab reachable from
# the public internet. Traefik's job here is service discovery, routing, and
# the request/latency metrics the nginx stub_status page cannot provide.
resource "docker_container" "traefik" {
  name     = "cinejo-traefik"
  image    = docker_image.traefik.image_id
  restart  = "unless-stopped"
  must_run = true

  command = [
    "--providers.docker=true",
    # Containers are opted in individually via labels; without this a new
    # container on this daemon would be published the moment it started.
    "--providers.docker.exposedbydefault=false",
    "--providers.docker.network=${docker_network.cinejo.name}",
    "--entrypoints.web.address=:80",
    # Metrics ride a separate entrypoint so they are never routable from
    # the public entrypoint.
    "--entrypoints.metrics.address=:8082",
    "--metrics.prometheus=true",
    "--metrics.prometheus.entrypoint=metrics",
    # Per-path latency histograms; without this only counters are emitted.
    "--metrics.prometheus.addrouterslabels=true",
    "--accesslog=true",
    "--accesslog.format=json",
    "--log.level=INFO",
    "--ping=true",
    "--ping.entrypoint=metrics",
  ]

  ports {
    internal = 80
    external = var.http_port
  }

  ports {
    internal = 8082
    external = var.traefik_metrics_port
  }

  # Read-only socket mount: Traefik only needs to watch container events and
  # read labels, never to create or modify containers. A writable socket
  # would hand any Traefik compromise full root-equivalent control of the
  # host, so this is the single most important line in the file.
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
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
}
