# Private bridge for the stack. The app and exporter containers publish no
# host ports of their own — Traefik is the only way in — so this network is
# the whole east-west surface.
resource "docker_network" "cinreco" {
  name   = "cinreco-web"
  driver = "bridge"
}
