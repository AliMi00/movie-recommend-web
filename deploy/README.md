# Deployment

Deployment is **pull-based**. GitHub Actions builds the image and pushes it
to GHCR; an agent on the deployment host polls the registry and rolls it
out. Nothing in CI can reach the host.

```
push to main ──▶ CI (lint, test, build, smoke)
                     │  on success
                     ▼
              Release ──▶ ghcr.io/<owner>/movie-recommend-web:<sha>, :latest
                                        │
                        (poll every 5m) │   outbound only
                                        ▼
                            deploy agent on the host
                              docker pull → digest changed?
                                        │ yes
                                        ▼
                              terraform apply → verify /healthz
```

## Why not deploy from CI

The host's SSH is reachable only over a private tailnet. Deploying from a
GitHub-hosted runner would require handing GitHub an SSH key plus a route
into that network; a self-hosted runner would be worse on a public
repository, because a pull request from a fork can execute arbitrary code
on the runner — inside the network.

Inverting the direction removes the problem rather than mitigating it.
There is no inbound firewall rule, no long-lived credential held by a third
party, and nothing to revoke if this repository is compromised. The cost is
latency: a release reaches production on the next poll rather than
instantly.

## One-time setup on the host

Requires Docker and Terraform.

```bash
# 1. Config (holds credentials — root-only)
sudo install -d -m 700 /etc/cinreco-web
sudo install -m 600 deploy/agent/deploy.env.example /etc/cinreco-web/deploy.env
sudo "$EDITOR" /etc/cinreco-web/deploy.env

# 2. Agent
sudo install -m 755 deploy/agent/cinreco-deploy.sh /usr/local/bin/cinreco-deploy.sh

# 3. Timer
sudo install -m 644 deploy/agent/cinreco-deploy.service /etc/systemd/system/
sudo install -m 644 deploy/agent/cinreco-deploy.timer   /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cinreco-deploy.timer
```

### Terraform state ownership

The agent runs `terraform apply` against the host's local Docker socket, so
**the state file must live on the host** — `/opt/cinreco-web/terraform/`.

If the stack was first applied from a workstation (over `ssh://`), that
state is on the workstation. Two state files describing the same containers
will fight: whichever one is missing the resources tries to create them and
fails on name conflicts. Hand ownership over once, before enabling the
timer:

```bash
# on the workstation, from terraform/
scp terraform.tfstate <host>:/opt/cinreco-web/terraform/terraform.tfstate
mv terraform.tfstate terraform.tfstate.handed-over   # keep as a backup
```

From then on the agent is the only thing that applies. Run workstation
`plan`s read-only if you want to preview a change, but let the agent apply
it.

For a multi-operator setup this is where a shared remote backend (S3 +
DynamoDB, Terraform Cloud, or a Postgres backend) would replace the local
file. A single-operator deployment does not need the extra moving part, and
local state keeps the whole deployment path dependency-free.

## Operating it

```bash
systemctl status cinreco-deploy.timer      # is it scheduled
systemctl list-timers cinreco-deploy       # when does it next run
journalctl -u cinreco-deploy -f            # deployment history
sudo systemctl start cinreco-deploy        # deploy now, don't wait
```

A tick with no new image logs `already running <id> — nothing to do` and
exits 0, so a short interval is cheap.

## Rolling back

Pin the previous image and deploy it:

```bash
sudo sed -i 's/^IMAGE_TAG=.*/IMAGE_TAG=<older-sha>/' /etc/cinreco-web/deploy.env
sudo systemctl start cinreco-deploy
```

Every release is tagged with its commit SHA, so a rollback is choosing a
tag rather than reverting and rebuilding. Set `IMAGE_TAG` back to `latest`
to resume tracking releases.
