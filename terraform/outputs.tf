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
  value       = "http://<this-host>:${var.metrics_port}/metrics"
}

output "traefik_metrics_endpoint" {
  description = "Prometheus scrape target for Traefik request rate and latency."
  value       = "http://<this-host>:${var.traefik_metrics_port}/metrics"
}

output "prometheus_url" {
  description = "Prometheus UI, on the private network only. Null when deploy_monitoring=false (no instance was created here)."
  value       = var.deploy_monitoring ? "http://<this-host>:${var.prometheus_port}" : null
}

output "grafana_url" {
  description = "Grafana UI (dashboard 'CineJo Web'), on the private network only. Null when deploy_monitoring=false — import monitoring/grafana/dashboards/cinejo-web.json into the shared Grafana instead."
  value       = var.deploy_monitoring ? "http://<this-host>:${var.grafana_port}/d/cinejo-web" : null
}

output "deployed_image" {
  description = "Image reference currently deployed."
  value       = var.app_image
}
