# Kubernetes Troubleshooting Lab

A production-style Kubernetes troubleshooting project covering five common incidents encountered by DevOps and SRE engineers.

## Project Stages

### 01 — ImagePullBackOff

Diagnosed Pods that could not start because of an invalid container image tag.

**Skills:** Kubernetes Events, image troubleshooting, rollout validation.

### 02 — CrashLoopBackOff

Investigated an application that repeatedly crashed because of missing configuration.

**Skills:** Pod logs, previous logs, exit codes, ConfigMaps, health probes.

### 03 — Pods Not Schedulable

Resolved Pending Pods caused by excessive CPU requests, incorrect node selectors, and untolerated taints.

**Skills:** Kubernetes scheduling, node labels, taints, tolerations, resource requests.

### 04 — StatefulSet and Persistent Storage

Troubleshot a StatefulSet blocked by a Pending PVC and invalid StorageClass.

**Skills:** StatefulSets, PVCs, PVs, StorageClasses, data persistence testing.

### 05 — NetworkPolicy

Diagnosed frontend-to-backend connectivity failures caused by default-deny rules, selector errors, and blocked DNS egress.

**Skills:** Calico, NetworkPolicy, DNS troubleshooting, ingress and egress security.

## Technologies

* Kubernetes
* Docker
* kind
* Calico
* kubectl
* Python
* NGINX
* Bash
* Git and GitHub

## Troubleshooting Workflow

```text
Detect issue
   ↓
Check resource status
   ↓
Inspect Events and logs
   ↓
Identify root cause
   ↓
Apply fix
   ↓
Validate recovery
   ↓
Document incident
```

## Project Structure

```text
incidents/
├── 01-imagepullbackoff/
├── 02-crashloopbackoff/
├── 03-pods-not-schedulable/
├── 04-statefulset-pv/
└── 05-networkpolicy/
```

Each stage includes broken manifests, fixed manifests, troubleshooting steps, evidence, a runbook, and an incident report.

## Skills Demonstrated

* Kubernetes troubleshooting
* Container debugging
* Scheduling and resource management
* Persistent storage
* Kubernetes networking
* Root cause analysis
* Incident response
* Technical documentation
