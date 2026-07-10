# Kubernetes Pods Not Schedulable

## Overview

This incident lab demonstrates how to diagnose and resolve Kubernetes Pods that remain in the `Pending` state because the scheduler cannot assign them to a node.

The project reproduces three common real-world scheduling failures:

1. Insufficient CPU resources
2. Node selector mismatch
3. Untolerated node taint

Each scenario includes:

* A broken Kubernetes manifest
* A repeatable troubleshooting procedure
* A corrected manifest
* Validation commands
* Incident evidence
* Root-cause documentation
* A cleanup script

---

## Learning Objectives

By completing this lab, you will learn how to:

* Identify unscheduled Kubernetes Pods
* Interpret `FailedScheduling` events
* Distinguish scheduling failures from application failures
* Inspect Pod resource requests
* Compare Pod requirements with node capacity
* Troubleshoot node selectors and node labels
* Understand Kubernetes taints and tolerations
* Verify Pod placement after remediation
* Document incidents using runbooks and incident reports

---

## Architecture

The lab runs on a multi-node Kubernetes cluster created with kind.

```text
Kubernetes Cluster
│
├── Control Plane
│
├── Application Worker
│   └── node-type=application
│
└── Database Worker
    ├── node-type=database
    └── dedicated=database:NoSchedule
```

The scheduling scenarios intentionally apply constraints that prevent Pods from being assigned to available nodes.

---

## Repository Structure

```text
03-pods-not-schedulable/
├── 01-insufficient-cpu/
│   ├── broken-deployment.yaml
│   └── fixed-deployment.yaml
│
├── 02-node-selector-mismatch/
│   ├── broken-deployment.yaml
│   └── fixed-deployment.yaml
│
├── 03-untolerated-taint/
│   ├── broken-deployment.yaml
│   └── fixed-deployment.yaml
│
├── evidence/
│   ├── events.txt
│   ├── node-capacity-and-taints.txt
│   ├── nodes-and-labels.txt
│   └── pods-after-fix.txt
│
├── cleanup.sh
├── incident-report.md
├── README.md
└── runbook.md
```

---

## Prerequisites

The following tools are required:

* Docker
* kubectl
* kind
* Git

Verify the tools:

```bash
docker --version
kubectl version --client
kind version
git --version
```

Confirm the cluster is running:

```bash
kubectl get nodes
```

Confirm the namespace exists:

```bash
kubectl get namespace troubleshooting-lab
```

Set the namespace as the current default:

```bash
kubectl config set-context \
  --current \
  --namespace=troubleshooting-lab
```

---

# Scenario 1: Insufficient CPU

## Incident Description

The Deployment requests more CPU than any node in the cluster can provide.

The scheduler evaluates resource requests before assigning a Pod to a node. Because no node has enough allocatable CPU, the Pod remains in the `Pending` state.

## Broken Configuration

```yaml
resources:
  requests:
    cpu: "100"
    memory: 64Mi
  limits:
    cpu: "100"
    memory: 128Mi
```

The Pod requests 100 CPU cores, which exceeds the capacity of the local kind nodes.

## Deploy the Broken Scenario

```bash
kubectl apply \
  -f 01-insufficient-cpu/broken-deployment.yaml
```

Check the Pod:

```bash
kubectl get pods \
  -l app=cpu-hungry-demo
```

Expected result:

```text
READY   STATUS    RESTARTS
0/1     Pending   0
```

## Troubleshooting

Store the Pod name:

```bash
POD_NAME=$(kubectl get pods \
  -l app=cpu-hungry-demo \
  -o jsonpath='{.items[0].metadata.name}')
```

Describe the Pod:

```bash
kubectl describe pod "$POD_NAME"
```

Review the `Events` section.

A typical scheduler message is:

```text
FailedScheduling
Insufficient cpu
```

Check the Pod resource request:

```bash
kubectl get pod "$POD_NAME" \
  -o jsonpath='CPU request: {.spec.containers[0].resources.requests.cpu}{"\n"}'
```

Check node allocatable resources:

```bash
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory'
```

## Root Cause

The Pod requested more CPU than any node could provide, so the scheduler could not find a suitable node.

## Resolution

The CPU request was reduced to a realistic value:

```yaml
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 128Mi
```

Apply the fix:

```bash
kubectl apply \
  -f 01-insufficient-cpu/fixed-deployment.yaml
```

Verify recovery:

```bash
kubectl rollout status deployment/cpu-hungry-demo
```

```bash
kubectl get pods \
  -l app=cpu-hungry-demo \
  -o wide
```

---

# Scenario 2: Node Selector Mismatch

## Incident Description

The Deployment requires a node label that does not exist in the cluster.

The Pod specifies:

```yaml
nodeSelector:
  workload-type: gpu
```

However, no node has the label:

```text
workload-type=gpu
```

As a result, the scheduler cannot place the Pod.

## Deploy the Broken Scenario

```bash
kubectl apply \
  -f 02-node-selector-mismatch/broken-deployment.yaml
```

Check the Pod:

```bash
kubectl get pods \
  -l app=selector-demo
```

Expected result:

```text
Pending
```

## Troubleshooting

Store the Pod name:

```bash
POD_NAME=$(kubectl get pods \
  -l app=selector-demo \
  -o jsonpath='{.items[0].metadata.name}')
```

Describe the Pod:

```bash
kubectl describe pod "$POD_NAME"
```

A typical scheduler message is:

```text
node(s) didn't match Pod's node affinity/selector
```

Inspect the Pod selector:

```bash
kubectl get pod "$POD_NAME" \
  -o jsonpath='{.spec.nodeSelector}{"\n"}'
```

Check whether any node matches:

```bash
kubectl get nodes \
  -l workload-type=gpu
```

Display node labels:

```bash
kubectl get nodes \
  -L node-type,workload-type
```

## Root Cause

The Pod required a node label that was not assigned to any node in the cluster.

## Resolution

The invalid selector was changed to match the application worker:

```yaml
nodeSelector:
  node-type: application
```

Apply the fix:

```bash
kubectl apply \
  -f 02-node-selector-mismatch/fixed-deployment.yaml
```

Verify the rollout:

```bash
kubectl rollout status deployment/selector-demo
```

Verify Pod placement:

```bash
kubectl get pods \
  -l app=selector-demo \
  -o wide
```

Confirm the selected node label:

```bash
POD_NAME=$(kubectl get pods \
  -l app=selector-demo \
  -o jsonpath='{.items[0].metadata.name}')

NODE_NAME=$(kubectl get pod "$POD_NAME" \
  -o jsonpath='{.spec.nodeName}')

kubectl get node "$NODE_NAME" \
  -o jsonpath='Node type: {.metadata.labels.node-type}{"\n"}'
```

Expected result:

```text
Node type: application
```

---

# Scenario 3: Untolerated Node Taint

## Incident Description

The database worker is configured with the following taint:

```text
dedicated=database:NoSchedule
```

The Pod is restricted to the database worker using a node selector, but it does not initially include a matching toleration.

The scheduler therefore refuses to place the Pod on the node.

## Prepare the Database Node

Find the database node:

```bash
DATABASE_NODE=$(kubectl get nodes \
  -l node-type=database \
  -o jsonpath='{.items[0].metadata.name}')
```

Apply the taint:

```bash
kubectl taint node "$DATABASE_NODE" \
  dedicated=database:NoSchedule
```

Verify it:

```bash
kubectl get node "$DATABASE_NODE" \
  -o jsonpath='{.spec.taints}{"\n"}'
```

## Deploy the Broken Scenario

```bash
kubectl apply \
  -f 03-untolerated-taint/broken-deployment.yaml
```

Check the Pod:

```bash
kubectl get pods \
  -l app=taint-demo
```

Expected result:

```text
Pending
```

## Troubleshooting

Store the Pod name:

```bash
POD_NAME=$(kubectl get pods \
  -l app=taint-demo \
  -o jsonpath='{.items[0].metadata.name}')
```

Describe the Pod:

```bash
kubectl describe pod "$POD_NAME"
```

A typical scheduler message is:

```text
node(s) had untolerated taint {dedicated: database}
```

Inspect the Pod selector:

```bash
kubectl get pod "$POD_NAME" \
  -o jsonpath='Node selector: {.spec.nodeSelector}{"\n"}'
```

Inspect the Pod tolerations:

```bash
kubectl get pod "$POD_NAME" \
  -o jsonpath='Tolerations: {.spec.tolerations}{"\n"}'
```

Inspect the node taint:

```bash
kubectl get node "$DATABASE_NODE" \
  -o jsonpath='Taints: {.spec.taints}{"\n"}'
```

## Root Cause

The Pod was restricted to the database node, but the node had a `NoSchedule` taint that the Pod did not tolerate.

## Resolution

A matching toleration was added:

```yaml
tolerations:
  - key: dedicated
    operator: Equal
    value: database
    effect: NoSchedule
```

Apply the fix:

```bash
kubectl apply \
  -f 03-untolerated-taint/fixed-deployment.yaml
```

Verify the rollout:

```bash
kubectl rollout status deployment/taint-demo
```

Verify placement:

```bash
kubectl get pods \
  -l app=taint-demo \
  -o wide
```

The Pod should now run on the database worker.

---

# Validation

Verify all corrected Deployments:

```bash
kubectl get deployments \
  cpu-hungry-demo \
  selector-demo \
  taint-demo
```

Verify all Pods:

```bash
kubectl get pods \
  -l incident=pods-not-schedulable \
  -o wide
```

Expected result:

```text
READY   STATUS    RESTARTS
1/1     Running   0
1/1     Running   0
1/1     Running   0
```

Display Pod placement:

```bash
kubectl get pods \
  -l incident=pods-not-schedulable \
  -o custom-columns='POD:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName'
```

Confirm that all Pods have a node assigned:

```bash
kubectl get pods \
  -l incident=pods-not-schedulable \
  -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.spec.nodeName}{"\n"}{end}'
```

---

# Troubleshooting Methodology

Use the following sequence for Pods that remain `Pending`.

## 1. Identify the Pod

```bash
kubectl get pods -A \
  --field-selector=status.phase=Pending
```

## 2. Describe the Pod

```bash
kubectl describe pod <pod-name> \
  -n <namespace>
```

The `Events` section usually contains the scheduler’s reason.

## 3. Check Node Assignment

```bash
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.nodeName}'
```

An empty value usually means the Pod has not been scheduled.

## 4. Check Resource Requests

```bash
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.containers[*].resources.requests}'
```

## 5. Inspect Nodes

```bash
kubectl get nodes --show-labels
```

```bash
kubectl describe node <node-name>
```

Review:

* Allocatable CPU
* Allocatable memory
* Node labels
* Taints
* Node conditions
* Allocated resources

## 6. Check Scheduling Constraints

Inspect:

```bash
kubectl get pod <pod-name> \
  -n <namespace> \
  -o yaml
```

Review:

* `nodeSelector`
* `affinity`
* `tolerations`
* Resource requests
* PersistentVolumeClaims

---

# Key Concepts

## Resource Requests

Resource requests represent the minimum CPU and memory required by a Pod.

The Kubernetes scheduler uses requests when selecting a node.

Example:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
```

CPU units:

```text
1000m = 1 CPU core
500m  = 0.5 CPU core
100m  = 0.1 CPU core
```

## Resource Limits

Limits control the maximum resources a container may consume after it starts.

```yaml
resources:
  limits:
    cpu: 500m
    memory: 256Mi
```

Requests affect scheduling. Limits affect runtime resource enforcement.

## Node Selectors

A node selector requires the destination node to contain matching labels.

```yaml
nodeSelector:
  node-type: application
```

## Taints

Taints prevent Pods from being scheduled onto a node unless they have a matching toleration.

```bash
kubectl taint node <node-name> \
  dedicated=database:NoSchedule
```

## Tolerations

A toleration allows a Pod to be considered for a node with a matching taint.

```yaml
tolerations:
  - key: dedicated
    operator: Equal
    value: database
    effect: NoSchedule
```

A toleration permits scheduling but does not force the Pod onto that node. A node selector or affinity rule may still be needed.

---

# Evidence Collection

Save the corrected Pod status:

```bash
kubectl get pods \
  -l incident=pods-not-schedulable \
  -o wide \
  > evidence/pods-after-fix.txt
```

Save node labels:

```bash
kubectl get nodes \
  -L node-type \
  > evidence/nodes-and-labels.txt
```

Save node capacity and taints:

```bash
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory,TAINTS:.spec.taints' \
  > evidence/node-capacity-and-taints.txt
```

Save cluster events:

```bash
kubectl get events \
  --sort-by=.metadata.creationTimestamp \
  > evidence/events.txt
```

Do not commit files containing:

* Credentials
* Tokens
* kubeconfig files
* Private keys
* Secret values
* Cloud-provider credentials

---

# Cleanup

Run:

```bash
./cleanup.sh
```

The cleanup script removes:

* `cpu-hungry-demo`
* `selector-demo`
* `taint-demo`
* The database-node taint

Verify cleanup:

```bash
kubectl get deployments
```

```bash
kubectl get pods
```

```bash
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
```

---

# Incident Summary

| Scenario               | Symptom               | Root Cause                        | Resolution              |
| ---------------------- | --------------------- | --------------------------------- | ----------------------- |
| Insufficient CPU       | Pod remains `Pending` | CPU request exceeds node capacity | Reduced CPU request     |
| Node selector mismatch | Pod remains `Pending` | No node matches required label    | Corrected node selector |
| Untolerated taint      | Pod remains `Pending` | Pod lacks matching toleration     | Added toleration        |

---

# Production Improvements

The following controls would reduce the likelihood of similar incidents in production:

* Validate resource requests during CI
* Use policy enforcement with Kyverno or OPA Gatekeeper
* Standardize node-label naming
* Manage node labels and taints through Infrastructure as Code
* Monitor Pods that remain Pending for more than five minutes
* Alert on `FailedScheduling` events
* Use capacity planning and cluster autoscaling
* Review Pod affinity and anti-affinity rules
* Document dedicated-node scheduling requirements
* Validate manifests before deployment

---

# Skills Demonstrated

This lab demonstrates practical experience with:

* Kubernetes scheduling
* Pending Pod troubleshooting
* Resource requests and limits
* Node labels and selectors
* Taints and tolerations
* Scheduler events
* Root-cause analysis
* Incident documentation
* Operational runbooks
* Git-based infrastructure management

---

# Resume Description

**Kubernetes Scheduling Troubleshooting Lab**

* Built a multi-node Kubernetes incident lab reproducing CPU resource shortages, node-selector mismatches, and untolerated node taints.
* Diagnosed unscheduled Pods using Kubernetes events, resource inspection, node capacity, labels, selectors, taints, and tolerations.
* Resolved workload-placement failures by correcting resource requests, node-selection rules, and scheduling tolerations.
* Created reusable incident runbooks, root-cause reports, evidence files, and cleanup automation for repeatable troubleshooting.

