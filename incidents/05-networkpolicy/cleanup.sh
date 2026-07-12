#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="networkpolicy-lab"

echo "Deleting the dedicated NetworkPolicy kind cluster..."

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind delete cluster --name "${CLUSTER_NAME}"
  echo "Cluster ${CLUSTER_NAME} deleted."
else
  echo "Cluster ${CLUSTER_NAME} does not exist."
fi
