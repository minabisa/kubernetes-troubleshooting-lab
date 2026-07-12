#!/usr/bin/env bash

set -euo pipefail

RELEASE="monitoring"
NAMESPACE="monitoring"

echo "Removing Helm release ${RELEASE}..."

helm uninstall "${RELEASE}" \
  --namespace "${NAMESPACE}" \
  2>/dev/null || true

echo
echo "The monitoring namespace and CRDs were not deleted automatically."
echo "This prevents accidental removal of unrelated monitoring resources."
echo
echo "To delete the namespace manually:"
echo "kubectl delete namespace ${NAMESPACE}"
