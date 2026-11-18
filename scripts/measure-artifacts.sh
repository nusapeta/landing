#!/usr/bin/env bash
# Reproduce the island artifact table and the RSS numbers printed on the page.
# Usage: scripts/measure-artifacts.sh [path-to-route-checkout]
set -euo pipefail

ROUTE_DIR="${1:-../routeid}"
BIN="$ROUTE_DIR/bin/nusa-serve"
INFO="$ROUTE_DIR/bin/nusa-graphinfo"
GRAPH="$ROUTE_DIR/data/java.graph"
PORT="${PORT:-18089}"
BASE="http://127.0.0.1:$PORT"

for f in "$BIN" "$INFO" "$GRAPH"; do
  if [[ ! -f "$f" ]]; then
    echo "missing: $f" >&2
    exit 1
  fi
done

echo "measurement_utc $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "route_head $(git -C "$ROUTE_DIR" rev-parse --short HEAD)"
echo "machine $(uname -srm)"
echo "binary $(basename "$BIN"), graph $(basename "$GRAPH")"
echo
echo "region	bytes	nodes	edges	format	built_at"
for r in java sumatra kalimantan sulawesi nusa-tenggara maluku papua; do
  f="$ROUTE_DIR/data/$r.graph"
  if [[ ! -f "$f" ]]; then
    printf '%s\tmissing\t-\t-\t-\t-\n' "$r"
    continue
  fi
  bytes=$(stat -c %s "$f")
  meta=$("$INFO" -graph "$f" 2>&1 || true)
  node_count=$(awk -F: '/^nodes / {gsub(/[[:space:]]/, "", $2); print $2; exit}' <<<"$meta")
  edge_count=$(awk -F: '/^edges / {gsub(/[[:space:]]/, "", $2); print $2; exit}' <<<"$meta")
  format=$(awk -F: '/^format / {gsub(/[[:space:]]/, "", $2); print $2; exit}' <<<"$meta")
  built=$(awk -F': ' '/^built at / {print $2; exit}' <<<"$meta")
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$r" "$bytes" "${node_count:-unsupported}" "${edge_count:-unsupported}" \
    "${format:-unsupported}" "${built:-unsupported}"
done

echo
"$BIN" -graph "$GRAPH" -addr "127.0.0.1:$PORT" -conc 1 -rate 0 \
  -timeout 10s -maxage 0 >/tmp/nusapeta-measure-server.log 2>&1 &
pid=$!
trap 'kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true' EXIT

for _ in $(seq 1 100); do
  if curl -sf "$BASE/healthz" -o /dev/null; then break; fi
  sleep 0.2
done
curl -sf "$BASE/healthz" -o /dev/null

sample() {
  grep -E '^(VmRSS|RssAnon|RssFile):' "/proc/$pid/status" | tr '\n' ' '
  echo
}

sleep 30
echo "idle_30s $(sample)"
for _ in $(seq 1 200); do
  curl -sf "$BASE/route?from=-6.1754,106.8272&to=-6.2444,106.8006" -o /dev/null
done
echo "after_200_routes $(sample)"
