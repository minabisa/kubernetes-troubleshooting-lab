#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="troubleshooting-lab"

kubectl delete deployment crashloop-demo \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

kubectl delete service crashloop-demo \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

kubectl delete configmap crashloop-demo-config \
  --namespace "${NAMESPACE}" \
  --ignore-not-found

echo "CrashLoopBackOff incident resources removed."
