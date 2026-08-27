terraform {
  required_version = ">= 1.5"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Talks to the deployment host's Docker daemon over SSH rather than exposing the
# daemon on a TCP port. The daemon socket is the root-equivalent control
# plane for the host, so tunnelling it through SSH — authenticated by an
# existing key, encrypted, no new listener — is the difference between a
# private management path and an internet-reachable one.
#
# The host string never appears in version control: it comes from a
# variable supplied via terraform.tfvars (gitignored) or TF_VAR_docker_host.
provider "docker" {
  host = var.docker_host
}
