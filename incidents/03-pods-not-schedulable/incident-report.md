# Incident Report: Pods Not Schedulable

## Incident ID

K8S-2026-003

## Severity

SEV-3

## Status

Resolved

## Environment

Local multi-node Kubernetes cluster created with kind.

## Summary

Several Kubernetes workloads remained Pending because their scheduling
requirements could not be satisfied by available nodes.

Three scheduling failures were reproduced:

1. A Pod requested more CPU than any node could provide.
2. A Pod used a node selector that did not match any node.
3. A Pod targeted a tainted node without the required toleration.

## Customer impact

The affected workloads had zero available replicas and could not serve
application traffic.

## Detection

The issue was detected using:

```bash
kubectl get pods

The Pods remained in the Pending state with zero restarts.

Investigation

The following commands were used:

kubectl describe pod <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get nodes --show-labels
kubectl describe node <node-name>
kubectl get pod <pod-name> -o yaml

The scheduler events reported:

Insufficient CPU
Node selector mismatch
Untolerated node taint
Root causes
Insufficient CPU

The Pod requested 100 CPU cores, exceeding the allocatable CPU capacity of
every node.

Node selector mismatch

The Pod required the label workload-type=gpu, but no cluster node had that
label.

Untolerated taint

The Pod was restricted to the database worker, which had the taint
dedicated=database:NoSchedule. The Pod did not have a matching toleration.

Resolution
CPU requests were corrected to realistic values.
The invalid node selector was changed to match the application worker.
A matching toleration was added for the database-node taint.
Validation

Recovery was verified using:

kubectl rollout status deployment/<deployment-name>
kubectl get pods -o wide
kubectl get events --sort-by=.metadata.creationTimestamp

All three workloads were successfully assigned to nodes and entered the
Running state.

Preventive actions
Validate resource requests during CI.
Establish standard resource-request ranges.
Manage node labels through infrastructure automation.
Document dedicated-node taints.
Validate selectors, affinity, and tolerations before deployment.
Alert when Pods remain Pending for longer than five minutes.
Monitor node capacity and aggregate requested resources.
