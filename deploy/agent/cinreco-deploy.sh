#!/usr/bin/env bash
#
# Pull-based deployment agent.
#
# Runs ON the deployment host (via systemd timer) rather than in CI, so the machine
# needs no inbound access at all: it reaches out to GitHub and GHCR, and
# nothing reaches in. CI's job ends at publishing an image; this decides
# when to adopt it.
#
# Each tick:
#   1. sync the repository (Terraform config is versioned with the app)
#   2. pull the watched image tag
#   3. compare the pulled digest with what is actually running
#   4. if they differ, terraform apply, then verify the rollout serves
#
# Exits 0 without touching anything when there is nothing new, so a short
# timer interval is cheap.
set -euo pipefail

CONFIG_FILE=${CONFIG_FILE:-/etc/cinreco-web/deploy.env}
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

: "${REPO_URL:?REPO_URL must be set}"
: "${REPO_DIR:=/opt/cinreco-web}"
: "${IMAGE_REPO:?IMAGE_REPO must be set}"
: "${IMAGE_TAG:=latest}"
: "${CONTAINER_NAME:=cinreco-web}"
: "${HEALTH_URL:=http://localhost:8060/healthz}"
: "${HEALTH_HOST_HEADER:=}"
: "${TF_DIR:=$REPO_DIR/terraform}"
: "${TERRAFORM_BIN:=terraform}"

log() { printf '%s  %s\n' "$(date -Is)" "$*"; }
fail() { log "ERROR: $*"; exit 1; }

IMAGE_REF="${IMAGE_REPO}:${IMAGE_TAG}"

# --- 1. sync repository -----------------------------------------------------
# Infrastructure changes ship the same way application changes do. The
# checkout is dedicated to deployment, so discarding local edits is safe;
# terraform.tfvars is gitignored and therefore untracked, so a hard reset
# leaves it in place.
if [[ ! -d "$REPO_DIR/.git" ]]; then
  log "cloning $REPO_URL -> $REPO_DIR"
  git clone --depth 1 "$REPO_URL" "$REPO_DIR"
else
  log "syncing $REPO_DIR"
  git -C "$REPO_DIR" fetch --depth 1 origin main --quiet
  git -C "$REPO_DIR" reset --hard origin/main --quiet
fi

# --- 2. pull the image ------------------------------------------------------
# GHCR_TOKEN is only needed if the package is private; a public package
# pulls anonymously and the variable can be left unset.
if [[ -n "${GHCR_TOKEN:-}" && -n "${GHCR_USER:-}" ]]; then
  printf '%s' "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin >/dev/null
fi

log "pulling $IMAGE_REF"
docker pull --quiet "$IMAGE_REF" >/dev/null || fail "could not pull $IMAGE_REF"

desired_id=$(docker image inspect --format '{{.Id}}' "$IMAGE_REF")

# --- 3. compare against what is running -------------------------------------
running_id=$(docker inspect --format '{{.Image}}' "$CONTAINER_NAME" 2>/dev/null || echo "")

if [[ -n "$running_id" && "$running_id" == "$desired_id" ]]; then
  log "already running ${desired_id:7:12} — nothing to do"
  exit 0
fi

if [[ -z "$running_id" ]]; then
  log "no running container; deploying ${desired_id:7:12}"
else
  log "update: ${running_id:7:12} -> ${desired_id:7:12}"
fi

# --- 4. apply ---------------------------------------------------------------
# app_image is passed explicitly so the deployed reference is always the one
# this script just verified, regardless of what tfvars happens to contain.
cd "$TF_DIR"
"$TERRAFORM_BIN" init -input=false -upgrade=false >/dev/null
"$TERRAFORM_BIN" apply -auto-approve -input=false -var "app_image=${IMAGE_REF}"

# --- 5. verify --------------------------------------------------------------
# An apply that succeeds while the app serves errors is still a failed
# deploy, so the rollout is not called done until it answers.
curl_args=(-s -o /dev/null -w '%{http_code}' --max-time 5)
[[ -n "$HEALTH_HOST_HEADER" ]] && curl_args+=(-H "Host: ${HEALTH_HOST_HEADER}")

for attempt in $(seq 1 20); do
  code=$(curl "${curl_args[@]}" "$HEALTH_URL" || echo 000)
  if [[ "$code" == "200" ]]; then
    log "deployed ${desired_id:7:12} — healthy"
    exit 0
  fi
  log "health check attempt ${attempt}: ${code}"
  sleep 3
done

log "rollout did not become healthy; recent container logs:"
docker logs --tail 50 "$CONTAINER_NAME" 2>&1 || true
exit 1
