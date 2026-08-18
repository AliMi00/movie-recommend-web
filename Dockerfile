# syntax=docker/dockerfile:1

# ---- Stage 1: compile the Flutter Web release ----
# Pinned to the same Flutter version the project is developed and tested
# against, so CI and local builds cannot drift.
FROM ghcr.io/cirruslabs/flutter:3.32.8 AS build

WORKDIR /app

# Dependencies resolve from the manifests alone, so copying them first
# keeps the pub-get layer cached across source-only changes.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# --no-web-resources-cdn bundles CanvasKit into the image instead of
# fetching it from gstatic at runtime: the container stays self-contained,
# the Content-Security-Policy needs no CDN origin, and first paint does not
# depend on a third-party host.
#
# The API URL is deliberately NOT baked in here — it is injected at
# container start by docker-entrypoint.sh, so one image serves every
# environment.
RUN flutter build web --release --no-web-resources-cdn

# ---- Stage 2: serve the static output ----
FROM nginx:1.27-alpine AS runtime

# curl backs the HEALTHCHECK below; nginx:alpine does not ship it.
RUN apk add --no-cache curl

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/build/web /usr/share/nginx/html
COPY docker-entrypoint.sh /docker-entrypoint.d/cinejo-entrypoint.sh

# The entrypoint rewrites index.html and nginx.conf in place at startup,
# so the nginx user needs write access to both.
RUN chmod +x /docker-entrypoint.d/cinejo-entrypoint.sh \
    && chown -R nginx:nginx /usr/share/nginx/html /etc/nginx \
    && chown nginx:nginx /docker-entrypoint.d/cinejo-entrypoint.sh

# Drop privileges: a container breakout from a root-run nginx is a far
# worse outcome than one from an unprivileged process.
USER nginx

# 8080 = app, 9113 = nginx stub_status for the Prometheus exporter.
EXPOSE 8080 9113

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -fsS http://localhost:8080/healthz || exit 1

ENTRYPOINT ["/docker-entrypoint.d/cinejo-entrypoint.sh"]
