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
    "ghcr.io/<owner>/cinejo-web:<sha>". The image must already be present on
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
    Host port Traefik listens on. The upstream reverse proxy (Caddy on the
    VPS, reached over Tailscale) forwards to this port.
  EOT
  type        = number
  default     = 8060
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

variable "api_base_url" {
  description = "Base URL of the CineJo API the browser client calls."
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
