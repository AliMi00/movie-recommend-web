# Every resource below is gated on var.deploy_monitoring: a host that
# already runs a shared Prometheus/Grafana (this repo does not know, and
# should not assume, it's the only app on the box) sets that to false and
# scrapes this app's metrics endpoints from the existing stack instead.

resource "docker_image" "prometheus" {
  count        = var.deploy_monitoring ? 1 : 0
  name         = "prom/prometheus:v3.1.0"
  keep_locally = true
}

resource "docker_image" "grafana" {
  count        = var.deploy_monitoring ? 1 : 0
  name         = "grafana/grafana:11.5.1"
  keep_locally = true
}

# Named volumes rather than bind mounts: the deployment host should not need
# directories provisioned outside Terraform, and Docker-managed volumes
# survive container replacement, so a redeploy does not discard history.
resource "docker_volume" "prometheus_data" {
  count = var.deploy_monitoring ? 1 : 0
  name  = "cinejo-prometheus-data"
}

resource "docker_volume" "grafana_data" {
  count = var.deploy_monitoring ? 1 : 0
  name  = "cinejo-grafana-data"
}

resource "docker_container" "prometheus" {
  count    = var.deploy_monitoring ? 1 : 0
  name     = "cinejo-prometheus"
  image    = docker_image.prometheus[0].image_id
  restart  = "unless-stopped"
  must_run = true

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
    # A single-app dashboard does not need a year of history, and an unbounded
    # TSDB on a small host eventually becomes the outage.
    "--storage.tsdb.retention.time=15d",
    "--web.enable-lifecycle",
  ]

  upload {
    file    = "/etc/prometheus/prometheus.yml"
    content = file("${path.module}/../monitoring/prometheus.yml")
  }

  volumes {
    volume_name    = docker_volume.prometheus_data[0].name
    container_path = "/prometheus"
  }

  # Published so it can be reached from the tailnet for ad-hoc queries.
  # Not routed through Traefik: metrics are operator tooling, and this
  # instance has no authentication of its own.
  ports {
    internal = 9090
    external = var.prometheus_port
  }

  networks_advanced {
    name = docker_network.cinejo.name
  }

  security_opts = ["no-new-privileges:true"]

  # Without this the scrape targets exist but are unreachable on first boot.
  depends_on = [docker_container.traefik, docker_container.metrics]
}


resource "docker_container" "grafana" {
  count    = var.deploy_monitoring ? 1 : 0
  name     = "cinejo-grafana"
  image    = docker_image.grafana[0].image_id
  restart  = "unless-stopped"
  must_run = true

  env = [
    "GF_SECURITY_ADMIN_USER=${var.grafana_admin_user}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    # Single-operator instance; open sign-up would only be a way in.
    "GF_USERS_ALLOW_SIGN_UP=false",
    "GF_ANALYTICS_REPORTING_ENABLED=false",
    "GF_ANALYTICS_CHECK_FOR_UPDATES=false",
  ]

  # Datasource and dashboard provider are configuration; the dashboard is
  # the committed artifact. All three are uploaded so a fresh container
  # comes up already wired, with no manual clicking in the UI.
  upload {
    file    = "/etc/grafana/provisioning/datasources/prometheus.yml"
    content = file("${path.module}/../monitoring/grafana/provisioning/datasources/prometheus.yml")
  }

  upload {
    file    = "/etc/grafana/provisioning/dashboards/dashboards.yml"
    content = file("${path.module}/../monitoring/grafana/provisioning/dashboards/dashboards.yml")
  }

  upload {
    file    = "/var/lib/grafana/dashboards/cinejo-web.json"
    content = file("${path.module}/../monitoring/grafana/dashboards/cinejo-web.json")
  }

  volumes {
    volume_name    = docker_volume.grafana_data[0].name
    container_path = "/var/lib/grafana"
  }

  ports {
    internal = 3000
    external = var.grafana_port
  }

  networks_advanced {
    name = docker_network.cinejo.name
  }

  security_opts = ["no-new-privileges:true"]

  depends_on = [docker_container.prometheus]
}
