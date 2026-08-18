#!/bin/sh
# Injects deployment configuration into the compiled web build at container
# start, so one image can be promoted across environments without rebuilding
# ("build once, run anywhere"). Flutter Web compiles to static JS and cannot
# read env vars at runtime, so the values are substituted into index.html,
# where the Dart side reads them back via JS interop (see web_config_real.dart).
set -eu

HTML_DIR=/usr/share/nginx/html
NGINX_CONF=/etc/nginx/nginx.conf

CINEJO_API_BASE_URL="${CINEJO_API_BASE_URL:-https://api.gozaga.xyz/v1}"
CINEJO_DEMO_EMAIL="${CINEJO_DEMO_EMAIL:-}"
CINEJO_DEMO_PASSWORD="${CINEJO_DEMO_PASSWORD:-}"
POSTHOG_API_KEY="${POSTHOG_API_KEY:-}"
POSTHOG_HOST="${POSTHOG_HOST:-https://eu.i.posthog.com}"

echo "[entrypoint] API base URL: ${CINEJO_API_BASE_URL}"
if [ -n "${CINEJO_DEMO_EMAIL}" ]; then
  echo "[entrypoint] demo account: enabled (${CINEJO_DEMO_EMAIL})"
else
  echo "[entrypoint] demo account: disabled"
fi
if [ -n "${POSTHOG_API_KEY}" ]; then
  echo "[entrypoint] analytics: enabled"
else
  echo "[entrypoint] analytics: disabled"
fi

# '|' as the sed delimiter because the values are URLs.
subst() {
  sed -i "s|$1|$2|g" "$3"
}

subst "__CINEJO_API_BASE_URL__"  "${CINEJO_API_BASE_URL}"  "${HTML_DIR}/index.html"
subst "__CINEJO_DEMO_EMAIL__"    "${CINEJO_DEMO_EMAIL}"    "${HTML_DIR}/index.html"
subst "__CINEJO_DEMO_PASSWORD__" "${CINEJO_DEMO_PASSWORD}" "${HTML_DIR}/index.html"
subst "__POSTHOG_API_KEY__"      "${POSTHOG_API_KEY}"      "${HTML_DIR}/index.html"
subst "__POSTHOG_API_HOST__"     "${POSTHOG_HOST}"         "${HTML_DIR}/index.html"

# The CSP must allow XHR to whichever API origin was just injected,
# otherwise the browser blocks every request the app makes. Derive the
# origin (scheme://host[:port]) from the base URL by dropping the path.
API_ORIGIN=$(echo "${CINEJO_API_BASE_URL}" | sed -E 's|^(https?://[^/]+).*|\1|')
CSP_CONNECT="${API_ORIGIN}"
if [ -n "${POSTHOG_API_KEY}" ]; then
  POSTHOG_ORIGIN=$(echo "${POSTHOG_HOST}" | sed -E 's|^(https?://[^/]+).*|\1|')
  CSP_CONNECT="${CSP_CONNECT} ${POSTHOG_ORIGIN}"
fi
subst "__CSP_CONNECT_SRC__" "${CSP_CONNECT}" "${NGINX_CONF}"
echo "[entrypoint] CSP connect-src: 'self' ${CSP_CONNECT}"

echo "[entrypoint] starting nginx"
exec nginx -g 'daemon off;'
