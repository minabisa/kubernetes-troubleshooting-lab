# Incident Report: StatefulSet Persistent Storage Failure

## Incident ID

K8S-2026-004

## Severity

SEV-3

## Status

Resolved

## Environment

Local multi-node Kubernetes cluster created with kind.

## Summary

A StatefulSet Pod remained Pending because its volumeClaimTemplate requested
a StorageClass that did not exist in the cluster.

Kubernetes could not dynamically provision a PersistentVolume. The generated
PersistentVolumeClaim remained Pending, preventing the StatefulSet Pod from
being scheduled.

## Customer impact

The stateful application had zero Ready replicas and could not serve traffic.

## Detection

The issue was detected using:

```bash
kubectl get statefulset
kubectl get pods
kubectl get pvc

The StatefulSet showed zero Ready replicas, the Pod remained Pending, and the
generated PVC remained Pending.

Investigation

The following commands were used:

kubectl describe pod stateful-web-0
kubectl describe pvc web-data-stateful-web-0
kubectl get storageclass
kubectl get pv
kubectl get events --sort-by=.metadata.creationTimestamp

The PVC requested:

nonexistent-storage-class

The cluster did not contain a StorageClass with that name.

Root cause

The StatefulSet volumeClaimTemplate referenced a nonexistent StorageClass.
Because no valid dynamic provisioner was associated with that class,
Kubernetes could not create a PersistentVolume for the claim.

Resolution

The broken StatefulSet and its unused Pending claim were removed.

The StatefulSet was recreated using the valid cluster StorageClass:

standard

Kubernetes dynamically provisioned a PersistentVolume and bound it to the
StatefulSet-generated PersistentVolumeClaim.

Validation

Recovery was validated using:

kubectl get statefulset stateful-web
kubectl get pod stateful-web-0
kubectl get pvc web-data-stateful-web-0
kubectl get pv

The PVC entered the Bound state and the StatefulSet Pod entered the Running
state.

A unique marker was written to the mounted volume. The Pod was then deleted
and recreated by the StatefulSet. The marker remained available after Pod
recreation, confirming persistent storage behavior.

Preventive actions
Validate StorageClass names during CI.
Verify CSI driver health before stateful deployments.
Alert on PVCs that remain Pending.
Alert on FailedAttachVolume and FailedMount events.
Manage StorageClasses through Infrastructure as Code.
Define production reclaim policies intentionally.
Test backup and restore procedures.
Document supported storage capacity and access modes.
Use admission policies to block invalid StorageClass references.
Avoid deleting production PVCs during troubleshooting.
