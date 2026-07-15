#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
DELAY_SECONDS="${DELAY_SECONDS:-0.2}"

echo "Generating continuous traffic against ${BASE_URL}"
echo "Press Control+C to stop."

while true; do
  RANDOM_VALUE=$((RANDOM % 100))

  if (( RANDOM_VALUE < 70 )); then
    ENDPOINT="/"
  elif (( RANDOM_VALUE < 85 )); then
    ENDPOINT="/health"
  elif (( RANDOM_VALUE < 95 )); then
    ENDPOINT="/slow"
  else
    ENDPOINT="/error"
  fi

  STATUS_CODE=$(
    curl \
      --silent \
      --output /dev/null \
      --write-out '%{http_code}' \
      --max-time 5 \
      "${BASE_URL}${ENDPOINT}" \
      || echo "000"
  )

  printf '%s endpoint=%s status=%s\n' \
    "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    "${ENDPOINT}" \
    "${STATUS_CODE}"

  sleep "${DELAY_SECONDS}"
done
