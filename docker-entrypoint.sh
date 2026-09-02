#!/bin/sh
# Injects deployment configuration into the compiled web build at container
# start, so one image can be promoted across environments without rebuilding
# ("build once, run anywhere"). Flutter Web compiles to static JS and cannot
# read env vars at runtime, so the values are substituted into index.html,
# where the Dart side reads them back via JS interop (see web_config_real.dart).
set -eu

# The app was renamed from Cinejo to CinReco. Each variable is read from its
# CINRECO_ name first and falls back to the old CINEJO_ name, so a container
# still started with the pre-rename environment keeps its configuration
# instead of silently dropping to defaults. Drop the CINEJO_ fallbacks once
# no deployment supplies them.
HTML_DIR=/usr/share/nginx/html
SECURITY_HEADERS=/etc/nginx/security-headers.conf

CINRECO_API_BASE_URL="${CINRECO_API_BASE_URL:-${CINEJO_API_BASE_URL:-https://api.gozaga.xyz/v1}}"
CINRECO_DEMO_EMAIL="${CINRECO_DEMO_EMAIL:-${CINEJO_DEMO_EMAIL:-}}"
CINRECO_DEMO_PASSWORD="${CINRECO_DEMO_PASSWORD:-${CINEJO_DEMO_PASSWORD:-}}"
POSTHOG_API_KEY="${POSTHOG_API_KEY:-}"
POSTHOG_HOST="${POSTHOG_HOST:-https://eu.i.posthog.com}"

echo "[entrypoint] API base URL: ${CINRECO_API_BASE_URL}"
if [ -n "${CINRECO_DEMO_EMAIL}" ]; then
  echo "[entrypoint] demo account: enabled (${CINRECO_DEMO_EMAIL})"
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

subst "__CINRECO_API_BASE_URL__"  "${CINRECO_API_BASE_URL}"  "${HTML_DIR}/index.html"
subst "__CINRECO_DEMO_EMAIL__"    "${CINRECO_DEMO_EMAIL}"    "${HTML_DIR}/index.html"
subst "__CINRECO_DEMO_PASSWORD__" "${CINRECO_DEMO_PASSWORD}" "${HTML_DIR}/index.html"
subst "__POSTHOG_API_KEY__"      "${POSTHOG_API_KEY}"      "${HTML_DIR}/index.html"
subst "__POSTHOG_API_HOST__"     "${POSTHOG_HOST}"         "${HTML_DIR}/index.html"

# The CSP must allow XHR to whichever API origin was just injected,
# otherwise the browser blocks every request the app makes. Derive the
# origin (scheme://host[:port]) from the base URL by dropping the path.
API_ORIGIN=$(echo "${CINRECO_API_BASE_URL}" | sed -E 's|^(https?://[^/]+).*|\1|')
CSP_CONNECT="${API_ORIGIN}"
CSP_SCRIPT=""
if [ -n "${POSTHOG_API_KEY}" ]; then
  POSTHOG_ORIGIN=$(echo "${POSTHOG_HOST}" | sed -E 's|^(https?://[^/]+).*|\1|')

  # PostHog Cloud serves its JS bundle and per-project remote config from a
  # SECOND host: <region>.i.posthog.com ingests events, while
  # <region>-assets.i.posthog.com serves array.js's follow-up config.js.
  # Allowing only the ingestion host gets you a loaded snippet that then
  # silently fails its config fetch. Self-hosted PostHog uses a single host,
  # where this pattern does not match and nothing extra is added.
  POSTHOG_ASSETS=$(echo "${POSTHOG_ORIGIN}" | sed -E 's|://([a-z0-9]+)\.i\.posthog\.com|://\1-assets.i.posthog.com|')

  CSP_CONNECT="${CSP_CONNECT} ${POSTHOG_ORIGIN}"
  # posthog-js bootstraps by injecting <script src="<host>/static/array.js">,
  # which script-src governs. Allowing it only under connect-src blocks the
  # loader outright, so no events are ever captured.
  CSP_SCRIPT="${POSTHOG_ORIGIN}"

  if [ "${POSTHOG_ASSETS}" != "${POSTHOG_ORIGIN}" ]; then
    CSP_CONNECT="${CSP_CONNECT} ${POSTHOG_ASSETS}"
    CSP_SCRIPT="${CSP_SCRIPT} ${POSTHOG_ASSETS}"
  fi
fi
subst "__CSP_CONNECT_SRC__" "${CSP_CONNECT}" "${SECURITY_HEADERS}"
subst "__CSP_SCRIPT_SRC__" "${CSP_SCRIPT}" "${SECURITY_HEADERS}"
echo "[entrypoint] CSP connect-src: 'self' ${CSP_CONNECT}"
echo "[entrypoint] CSP script-src extra: '${CSP_SCRIPT:-none}'"

echo "[entrypoint] starting nginx"
exec nginx -g 'daemon off;'
