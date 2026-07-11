# 🚀 Stage 04 – Kubernetes StatefulSet & Persistent Volume Troubleshooting

A production-style Kubernetes troubleshooting lab that reproduces and resolves a common storage-related incident involving **StatefulSets**, **PersistentVolumeClaims (PVCs)**, **PersistentVolumes (PVs)**, and **StorageClasses**.

This lab demonstrates how a misconfigured StorageClass prevents dynamic volume provisioning, causing a StatefulSet Pod to remain in the **Pending** state. The incident is investigated, resolved, and validated by verifying data persistence across Pod recreation.

---

# 📖 Table of Contents

* Overview
* Learning Objectives
* Architecture
* Repository Structure
* Technologies Used
* Incident Scenario
* Investigation Workflow
* Root Cause
* Resolution
* Validation
* Persistence Test
* Skills Demonstrated
* Lessons Learned

---

# 📌 Overview

Stateful applications require persistent storage to preserve data across Pod restarts or rescheduling.

In Kubernetes, StatefulSets automatically create a dedicated PersistentVolumeClaim (PVC) for each replica using `volumeClaimTemplates`.

If the requested **StorageClass** does not exist or storage provisioning fails, the PVC remains **Pending**, preventing the StatefulSet Pod from starting.

This lab reproduces that failure and demonstrates a structured troubleshooting process to identify and resolve the issue.

---

# 🎯 Learning Objectives

After completing this lab, you will be able to:

* Deploy stateful applications using StatefulSets
* Understand the relationship between StatefulSets, PVCs, PVs, and StorageClasses
* Troubleshoot Pending Pods caused by storage provisioning failures
* Investigate PersistentVolumeClaims and PersistentVolumes
* Diagnose StorageClass configuration issues
* Validate dynamic volume provisioning
* Verify persistent storage survives Pod recreation
* Document storage incidents using professional runbooks and incident reports

---

# 🏗 Architecture

```text
                    Client
                       │
                       ▼
               Headless Service
                       │
                       ▼
              StatefulSet (1 Replica)
                       │
                       ▼
        volumeClaimTemplate (PVC)
                       │
                       ▼
              StorageClass
                       │
                       ▼
             PersistentVolume
```

---

# 📁 Repository Structure

```text
04-statefulset-pv/
│
├── broken/
│   ├── headless-service.yaml
│   └── statefulset.yaml
│
├── fixed/
│   ├── headless-service.yaml
│   └── statefulset.yaml
│
├── evidence/
│   ├── events.txt
│   ├── pod-after-fix.txt
│   ├── pvc-after-fix.txt
│   ├── pv-after-fix.yaml
│   ├── persistence-test.txt
│   ├── pod-recreation.txt
│   └── statefulset-after-fix.txt
│
├── cleanup.sh
├── incident-report.md
├── runbook.md
└── README.md
```

---

# 🛠 Technologies Used

* Kubernetes
* kind
* kubectl
* Docker
* StatefulSets
* PersistentVolumes (PV)
* PersistentVolumeClaims (PVC)
* StorageClasses
* Headless Services
* NGINX (Unprivileged)

---

# 🚨 Incident Scenario

## Problem

A StatefulSet is deployed using a `volumeClaimTemplate`.

The generated PersistentVolumeClaim requests the following StorageClass:

```yaml
storageClassName: nonexistent-storage-class
```

Because the StorageClass does not exist, Kubernetes cannot dynamically provision a PersistentVolume.

As a result:

* The PVC remains **Pending**
* The StatefulSet Pod remains **Pending**
* The application never starts

---

# 🔍 Investigation Workflow

The investigation follows a structured production troubleshooting process.

## 1. Verify StatefulSet status

```bash
kubectl get statefulset
```

## 2. Check Pod status

```bash
kubectl get pods
```

## 3. Describe the StatefulSet Pod

```bash
kubectl describe pod stateful-web-0
```

The Events section reports:

```text
pod has unbound immediate PersistentVolumeClaims
```

## 4. Inspect the PersistentVolumeClaim

```bash
kubectl get pvc
kubectl describe pvc web-data-stateful-web-0
```

The PVC remains:

```text
Pending
```

## 5. Verify available StorageClasses

```bash
kubectl get storageclass
```

The requested StorageClass does not exist.

## 6. Inspect PersistentVolumes

```bash
kubectl get pv
```

No PersistentVolume has been provisioned for the claim.

## 7. Review Kubernetes Events

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

The events confirm that dynamic provisioning failed due to an invalid StorageClass.

---

# 🧩 Root Cause

The StatefulSet requested a StorageClass named:

```text
nonexistent-storage-class
```

Since the cluster did not contain a StorageClass with that name, Kubernetes could not dynamically provision a PersistentVolume.

The generated PersistentVolumeClaim remained **Pending**, preventing the StatefulSet Pod from being scheduled.

---

# ✅ Resolution

The StatefulSet was updated to reference the cluster's valid StorageClass:

```yaml
storageClassName: standard
```

The broken StatefulSet and its unused Pending PVC were removed.

The corrected StatefulSet was then redeployed.

Kubernetes successfully:

* Created a PersistentVolume
* Bound the PersistentVolumeClaim
* Started the StatefulSet Pod

---

# ✔ Validation

Recovery was verified using:

```bash
kubectl get statefulset
```

```bash
kubectl get pods
```

```bash
kubectl get pvc
```

```bash
kubectl get pv
```

Expected results:

| Resource    | Status      |
| ----------- | ----------- |
| StatefulSet | Ready (1/1) |
| Pod         | Running     |
| PVC         | Bound       |
| PV          | Bound       |

---

# 💾 Persistence Verification

To verify persistent storage:

1. A unique marker file was written to the mounted volume.
2. The StatefulSet Pod was deleted.
3. Kubernetes automatically recreated the Pod.
4. The marker file remained available after recreation.

This confirms that application data persists independently of the Pod lifecycle.

---

# 📊 Skills Demonstrated

* Kubernetes StatefulSets
* Dynamic Storage Provisioning
* Persistent Volumes (PV)
* PersistentVolumeClaims (PVC)
* StorageClasses
* Headless Services
* VolumeClaimTemplates
* Kubernetes Events
* Root Cause Analysis
* Incident Response
* Operational Documentation

---

# 📚 Lessons Learned

* Stateful workloads require correctly configured storage resources.
* A Pending PersistentVolumeClaim prevents StatefulSet Pods from starting.
* Kubernetes Events provide the fastest indication of storage provisioning failures.
* PersistentVolumes outlive Pods and preserve application data.
* Storage validation should be included in deployment pipelines to prevent production incidents.

---

# 📌 Key Takeaways

✅ Diagnosed a StatefulSet deployment failure caused by an invalid StorageClass.

✅ Investigated Kubernetes storage resources including StatefulSets, PVCs, PVs, and StorageClasses.

✅ Restored application availability by correcting the storage configuration.

✅ Verified data persistence across Pod recreation using StatefulSet-managed storage.

✅ Documented the incident with reusable runbooks, evidence, and operational procedures.
