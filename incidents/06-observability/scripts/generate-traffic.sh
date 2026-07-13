#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
NORMAL_REQUESTS="${NORMAL_REQUESTS:-50}"
SLOW_REQUESTS="${SLOW_REQUESTS:-10}"
ERROR_REQUESTS="${ERROR_REQUESTS:-10}"

echo "Generating ${NORMAL_REQUESTS} normal requests..."

for _ in $(seq 1 "${NORMAL_REQUESTS}"); do
  curl \
    --silent \
    --output /dev/null \
    "${BASE_URL}/"
done

echo "Generating ${SLOW_REQUESTS} slow requests..."

for _ in $(seq 1 "${SLOW_REQUESTS}"); do
  curl \
    --silent \
    --output /dev/null \
    "${BASE_URL}/slow"
done

echo "Generating ${ERROR_REQUESTS} error requests..."

for _ in $(seq 1 "${ERROR_REQUESTS}"); do
  curl \
    --silent \
    --output /dev/null \
    "${BASE_URL}/error" || true
done

echo "Traffic generation completed."
