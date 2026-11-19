#!/usr/bin/env bash
# Reproduce the artifact table (national and island graphs) and the RSS numbers
# printed on the page.
# Usage: scripts/measure-artifacts.sh [path-to-route-checkout]
set -euo pipefail

ROUTE_DIR="${1:-../routeid}"
BIN="$ROUTE_DIR/bin/nusa-serve"
INFO="$ROUTE_DIR/bin/nusa-graphinfo"
GRAPHS_RSS_JAVA="$ROUTE_DIR/data/java.graph"
# The deployed national graph is the current build; override it when the
# checkout keeps an older data/indonesia.graph around.
NATIONAL_GRAPH="${NATIONAL_GRAPH:-$ROUTE_DIR/data/indonesia.graph}"
GRAPHS_RSS_NATIONAL="$NATIONAL_GRAPH"
PORT="${PORT:-18089}"
BASE="http://127.0.0.1:$PORT"

for f in "$BIN" "$INFO" "$GRAPHS_RSS_JAVA"; do
  if [[ ! -f "$f" ]]; then
    echo "missing: $f" >&2
    exit 1
  fi
done

echo "measurement_utc $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "route_head $(git -C "$ROUTE_DIR" rev-parse --short HEAD)"
echo "machine $(uname -srm)"
echo "binary $BIN"
echo
echo "region	bytes	nodes	edges	format	built_at"
for r in indonesia java sumatra kalimantan sulawesi nusa-tenggara maluku papua; do
  f="$ROUTE_DIR/data/$r.graph"
  [[ "$r" == indonesia ]] && f="$NATIONAL_GRAPH"
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

trap 'kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true' EXIT

# Idle and loaded RSS for one graph, read from /proc/<pid>/status: 30 s of idle
# settle then 200 sequential Jakarta routes on the same process.
measure_rss() {
  local graph="$1"
  echo
  "$BIN" -graph "$graph" -addr "127.0.0.1:$PORT" -conc 1 -rate 0 \
    -timeout 10s -maxage 0 >/tmp/nusapeta-measure-server.log 2>&1 &
  pid=$!
  for _ in $(seq 1 300); do
    if curl -sf "$BASE/healthz" -o /dev/null; then break; fi
    if ! kill -0 "$pid" 2>/dev/null; then
      echo "${graph##*/} failed to start" >&2
      cat /tmp/nusapeta-measure-server.log >&2
      return 1
    fi
    sleep 0.2
  done
  curl -sf "$BASE/healthz" -o /dev/null
  sleep 30
  echo "idle_30s ${graph##*/} $(sample)"
  for _ in $(seq 1 200); do
    curl -sf "$BASE/route?from=-6.1754,106.8272&to=-6.2444,106.8006" -o /dev/null
  done
  echo "after_200_routes ${graph##*/} $(sample)"
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

sample() {
  grep -E '^(VmRSS|RssAnon|RssFile):' "/proc/$pid/status" | tr '\n' ' '
  echo
}

measure_rss "$GRAPHS_RSS_JAVA"
measure_rss "$GRAPHS_RSS_NATIONAL"
