variable "docker_host" {
  description = <<-EOT
    Docker daemon endpoint, e.g. "ssh://user@host" or "ssh://alias" when the
    host is defined in ~/.ssh/config. Never commit a real value — set it in
    terraform.tfvars (gitignored) or export TF_VAR_docker_host.
  EOT
  type        = string
  # No default on purpose: a wrong-but-plausible default risks deploying
  # somewhere unintended.
}

variable "app_image" {
  description = <<-EOT
    Fully-qualified image reference to deploy, e.g.
    "ghcr.io/<owner>/cinreco-web:<sha>". The image must already be present on
    the target daemon — CI pulls it before running Terraform. Pinning to an
    immutable tag (a commit SHA) rather than :latest is what makes a rollback
    a one-line variable change.
  EOT
  type        = string
}

variable "public_domain" {
  description = "Hostname the app is served on; becomes the Traefik router rule."
  type        = string
}

variable "http_port" {
  description = <<-EOT
    Host port Traefik listens on. The upstream reverse proxy (Caddy)
    forwards to this port.
  EOT
  type        = number
  default     = 8060
}

variable "traefik_bind_ip" {
  description = <<-EOT
    Interface Traefik's HTTP entrypoint binds to on the host. Two real
    topologies use this repo:
      - Caddy runs on a *different* machine and reaches this host over
        Tailscale (the original homelab setup) -> bind "0.0.0.0" so the
        tailnet interface is reachable. The OS firewall on that host has no
        public inbound rule at all, so this is not exposed to the internet.
      - Caddy runs locally on this same host (e.g. a VPS with 80/443 open
        to the public) -> bind "127.0.0.1" so the app port is reachable
        only from the same machine, never from the network, regardless of
        what the firewall allows.
    Pick the one that matches where Caddy actually runs.
  EOT
  type        = string
  default     = "0.0.0.0"
}

variable "deploy_monitoring" {
  description = <<-EOT
    Whether this Terraform config should run its own Prometheus + Grafana.
    Set to false on a host that already runs a shared monitoring stack —
    scrape this app's metrics endpoints (nginx_metrics_endpoint,
    traefik_metrics_endpoint in outputs.tf) from that stack instead, and
    import monitoring/grafana/dashboards/cinreco-web.json into its Grafana
    by hand. Running a second Prometheus/Grafana per app does not scale
    and duplicates data a shared instance already has.
  EOT
  type        = bool
  default     = true
}

variable "metrics_port" {
  description = "Host port exposing the nginx Prometheus exporter."
  type        = number
  default     = 8062
}

variable "traefik_metrics_port" {
  description = "Host port exposing Traefik's own Prometheus metrics."
  type        = number
  default     = 8063
}

variable "prometheus_port" {
  description = "Host port for Prometheus. Reachable on the private network only."
  type        = number
  default     = 8064
}

variable "grafana_port" {
  description = "Host port for Grafana. Reachable on the private network only."
  type        = number
  default     = 8065
}

variable "grafana_admin_user" {
  description = "Grafana admin username."
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = <<-EOT
    Grafana admin password. Supply via TF_VAR_grafana_admin_password or
    tfvars; never commit. Only applied when the Grafana data volume is first
    created — changing it later requires resetting it inside Grafana.
  EOT
  type        = string
  sensitive   = true
}

variable "api_base_url" {
  description = "Base URL of the CinReco API the browser client calls."
  type        = string
  default     = "https://api.gozaga.xyz/v1"
}

variable "demo_email" {
  description = <<-EOT
    Shared demo account address. When set together with demo_password, the
    app shows a "Continue with Demo Account" button. Leave empty to disable.
  EOT
  type        = string
  default     = ""
}

variable "demo_password" {
  description = "Password for the shared demo account. Supply via TF_VAR_demo_password or tfvars; never commit."
  type        = string
  default     = ""
  sensitive   = true
}

variable "posthog_api_key" {
  description = "Optional PostHog project key. Empty disables analytics entirely."
  type        = string
  default     = ""
  sensitive   = true
}

variable "posthog_host" {
  description = "PostHog ingestion host."
  type        = string
  default     = "https://eu.i.posthog.com"
}
