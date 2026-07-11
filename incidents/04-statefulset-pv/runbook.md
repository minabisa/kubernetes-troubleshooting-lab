# StatefulSet and Persistent Volume Troubleshooting Runbook

## Purpose

This runbook provides a repeatable process for diagnosing StatefulSet Pods
that cannot start because of PersistentVolume or PersistentVolumeClaim
problems.

## Common symptoms

- StatefulSet shows zero Ready replicas
- Pod remains Pending
- PVC remains Pending
- Pod reports an unbound PersistentVolumeClaim
- Volume cannot be attached
- Volume cannot be mounted
- StatefulSet Pod starts but application data is unavailable

## Common causes

1. StorageClass does not exist
2. CSI driver or storage provisioner is unavailable
3. PVC requests an unsupported access mode
4. No PersistentVolume matches the claim
5. Storage capacity request cannot be satisfied
6. Volume topology conflicts with Pod scheduling
7. Volume attachment failure
8. Volume mount failure
9. File permissions or ownership mismatch
10. Incorrect volumeMount or claim name
11. Zone or node-affinity mismatch
12. Cloud-provider permissions failure

## Investigation procedure

### 1. Check the StatefulSet

```bash
kubectl get statefulset \
  -n <namespace>
kubectl describe statefulset <statefulset-name> \
  -n <namespace>
2. Check the Pods
kubectl get pods \
  -n <namespace> \
  -l app=<application-label> \
  -o wide
3. Describe the affected Pod
kubectl describe pod <pod-name> \
  -n <namespace>

Review the Events section for:

unbound PersistentVolumeClaims
FailedAttachVolume
FailedMount
node-affinity conflicts
scheduling failures
4. Check PersistentVolumeClaims
kubectl get pvc \
  -n <namespace>
kubectl describe pvc <pvc-name> \
  -n <namespace>

Review:

Status
StorageClass
Requested capacity
Access mode
Bound volume
Events
5. Check the requested StorageClass
kubectl get pvc <pvc-name> \
  -n <namespace> \
  -o jsonpath='{.spec.storageClassName}'
6. List available StorageClasses
kubectl get storageclass
kubectl describe storageclass <storageclass-name>
7. Check PersistentVolumes
kubectl get pv
kubectl describe pv <pv-name>

Review:

Status
Capacity
Access modes
StorageClass
Claim reference
Reclaim policy
Node affinity
8. Inspect PVC events
kubectl get events \
  -n <namespace> \
  --field-selector involvedObject.name=<pvc-name> \
  --sort-by=.metadata.creationTimestamp
9. Inspect Pod events
kubectl get events \
  -n <namespace> \
  --field-selector involvedObject.name=<pod-name> \
  --sort-by=.metadata.creationTimestamp
10. Check storage provisioner components

The exact command depends on the cluster and CSI driver.

Examples:

kubectl get pods -A | grep -E 'csi|provisioner|storage'

Check the logs of the relevant provisioner only after identifying it:

kubectl logs <provisioner-pod> \
  -n <provisioner-namespace>
11. Inspect volume configuration
kubectl get statefulset <statefulset-name> \
  -n <namespace> \
  -o yaml

Review:

volumeClaimTemplates
storageClassName
accessModes
storage request
volumeMounts
volume names
securityContext
12. Verify recovery
kubectl get pvc \
  -n <namespace>

The claim should be Bound.

kubectl get pods \
  -n <namespace> \
  -o wide

The Pod should be Running and Ready.

kubectl exec <pod-name> \
  -n <namespace> \
  -- mount

Verify that the expected volume is mounted.

Persistence validation
Write a unique marker to the mounted volume.
Record the existing Pod UID.
Delete the Pod.
Wait for the StatefulSet to recreate it.
Confirm the new Pod UID is different.
Confirm the original marker still exists.
Escalation criteria

Escalate when:

Multiple PVCs fail to provision
The CSI controller or node plugin is unavailable
Cloud-provider API calls are failing
Volume attachment errors affect multiple nodes
A production volume appears corrupted
A production PVC or PV is at risk of deletion
Restoring service requires changing reclaim policies
Backups or snapshots are unavailable
