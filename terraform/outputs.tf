output "public_url" {
  description = "URL the app is served on, via the upstream reverse proxy."
  value       = "https://${var.public_domain}"
}

output "traefik_entrypoint" {
  description = "Host port the upstream reverse proxy should forward to."
  value       = var.http_port
}

output "nginx_metrics_endpoint" {
  description = "Prometheus scrape target for nginx connection/request metrics."
  value       = "http://<homelab-host>:${var.metrics_port}/metrics"
}

output "traefik_metrics_endpoint" {
  description = "Prometheus scrape target for Traefik request rate and latency."
  value       = "http://<homelab-host>:${var.traefik_metrics_port}/metrics"
}

output "prometheus_url" {
  description = "Prometheus UI, on the private network only."
  value       = "http://<homelab-host>:${var.prometheus_port}"
}

output "grafana_url" {
  description = "Grafana UI (dashboard 'CineJo Web'), on the private network only."
  value       = "http://<homelab-host>:${var.grafana_port}/d/cinejo-web"
}

output "deployed_image" {
  description = "Image reference currently deployed."
  value       = var.app_image
}
