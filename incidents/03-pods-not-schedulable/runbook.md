# Pods Not Schedulable Troubleshooting Runbook

## Purpose

This runbook provides a repeatable procedure for diagnosing Kubernetes Pods
that remain Pending because the scheduler cannot place them on a node.

## Important distinction

A Pending Pod has not necessarily failed at the application level.

If `.spec.nodeName` is empty, the scheduler has not assigned the Pod to a node,
and the container has not started.

## Common causes

1. Insufficient CPU
2. Insufficient memory
3. Node selector mismatch
4. Required node affinity mismatch
5. Untolerated node taint
6. Pod anti-affinity restrictions
7. Unbound PersistentVolumeClaim
8. Maximum Pod capacity reached on nodes
9. Host port conflict
10. Namespace resource quota restrictions

## Investigation procedure

### 1. Identify Pending Pods

```bash
kubectl get pods -A \
  --field-selector=status.phase=Pending
2. Describe the Pod
kubectl describe pod <pod-name> \
  -n <namespace>

Review the Events section for FailedScheduling.

3. Check whether a node was assigned
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.nodeName}'

An empty result usually means the Pod has not been scheduled.

4. Inspect scheduling events
kubectl get events \
  -n <namespace> \
  --field-selector involvedObject.name=<pod-name> \
  --sort-by=.metadata.creationTimestamp
5. Inspect resource requests
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.containers[*].resources.requests}'
6. Compare requests with node capacity
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory'
kubectl describe node <node-name>

Review:

Capacity
Allocatable
Allocated resources
Conditions
Taints
7. Inspect node selectors
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.nodeSelector}'

Compare them with:

kubectl get nodes --show-labels
8. Inspect affinity rules
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.affinity}'
9. Inspect node taints
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
10. Inspect Pod tolerations
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.tolerations}'
11. Check persistent storage
kubectl get pvc -n <namespace>

A Pod may remain Pending when it depends on an unbound PVC.

12. Apply the correction

Possible corrections include:

Reduce unrealistic resource requests
Add cluster capacity
Correct node labels or selectors
Correct node-affinity rules
Add an appropriate toleration
Remove an incorrect taint
Resolve an unbound PVC
Adjust Pod anti-affinity rules
13. Verify recovery
kubectl get pod <pod-name> \
  -n <namespace> \
  -o wide
kubectl rollout status deployment/<deployment-name> \
  -n <namespace>

Confirm that:

A node is assigned
Pod phase is Running
Containers are Ready
Restart count is stable
