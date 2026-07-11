#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="troubleshooting-lab"
STATEFULSET="stateful-web"
SERVICE="stateful-web"
PVC="web-data-stateful-web-0"

echo "Deleting StatefulSet..."
kubectl delete statefulset "${STATEFULSET}" \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

echo "Deleting Service..."
kubectl delete service "${SERVICE}" \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

echo
echo "The PVC is not deleted automatically to reduce accidental data loss."
echo "Current PVC status:"

kubectl get pvc "${PVC}" \
  --namespace "${NAMESPACE}" \
  2>/dev/null || true

echo
echo "To permanently remove the lab data, run:"
echo "kubectl delete pvc ${PVC} --namespace ${NAMESPACE}"
