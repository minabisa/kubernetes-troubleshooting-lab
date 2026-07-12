#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="monitoring"

cat <<MESSAGE
Observability stack access

Grafana:
  kubectl port-forward -n ${NAMESPACE} service/monitoring-grafana 3000:80
  URL: http://localhost:3000

Prometheus:
  kubectl port-forward -n ${NAMESPACE} service/monitoring-prometheus 9090:9090
  URL: http://localhost:9090

Alertmanager:
  kubectl port-forward -n ${NAMESPACE} service/monitoring-alertmanager 9093:9093
  URL: http://localhost:9093
MESSAGE
