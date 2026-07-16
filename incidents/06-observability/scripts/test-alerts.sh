#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
TEST="${1:-}"

usage() {
  cat <<USAGE
Usage:
  $0 errors
  $0 latency
  $0 cpu

The observability-demo Service must be port-forwarded to localhost:8080.
Press Control+C to stop a sustained test.
USAGE
}

case "${TEST}" in
  errors)
    echo "Generating sustained HTTP 500 traffic..."

    while true; do
      for _ in $(seq 1 20); do
        curl \
          --silent \
          --output /dev/null \
          "${BASE_URL}/error"
      done

      for _ in $(seq 1 5); do
        curl \
          --silent \
          --output /dev/null \
          "${BASE_URL}/"
      done

      sleep 1
    done
    ;;

  latency)
    echo "Generating sustained slow requests..."

    while true; do
      seq 1 20 |
        xargs \
          -n1 \
          -P20 \
          curl \
          --silent \
          --output /dev/null \
          "${BASE_URL}/slow"

      sleep 1
    done
    ;;

  cpu)
    echo "Generating sustained CPU load..."

    while true; do
      seq 1 30 |
        xargs \
          -n1 \
          -P30 \
          curl \
          --silent \
          --output /dev/null \
          "${BASE_URL}/cpu"
    done
    ;;

  *)
    usage
    exit 1
    ;;
esac
