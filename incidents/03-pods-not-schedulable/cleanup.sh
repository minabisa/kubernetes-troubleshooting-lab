#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="troubleshooting-lab"

kubectl delete deployment cpu-hungry-demo \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

kubectl delete deployment selector-demo \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

kubectl delete deployment taint-demo \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

DATABASE_NODE=$(kubectl get nodes \
  -l node-type=database \
  -o jsonpath='{.items[0].metadata.name}')

if [[ -n "${DATABASE_NODE}" ]]; then
  kubectl taint node "${DATABASE_NODE}" \
    dedicated=database:NoSchedule- \
    2>/dev/null || true
fi

echo "Pods-not-schedulable incident resources removed."
