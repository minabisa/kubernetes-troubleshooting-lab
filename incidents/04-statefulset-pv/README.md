Kubernetes Troubleshooting Lab – Stage 04: StatefulSet & Persistent Volume
Overview

This project demonstrates how to troubleshoot one of the most common storage-related incidents in Kubernetes: a StatefulSet Pod that cannot start because its PersistentVolumeClaim (PVC) cannot be provisioned.

The lab reproduces a production-style storage failure, walks through the complete investigation process, applies the appropriate fix, and verifies persistent data survives Pod recreation.

This scenario is designed to simulate the type of storage incidents commonly encountered by DevOps and Site Reliability Engineers in production Kubernetes environments.

Objectives

After completing this lab, you will be able to:

Deploy stateful applications using StatefulSets
Understand the relationship between StatefulSets, Services, PVCs, PVs, and StorageClasses
Troubleshoot Pending Pods caused by storage provisioning failures
Investigate PVC and PV lifecycle events
Diagnose StorageClass configuration issues
Validate dynamic volume provisioning
Verify persistent storage survives Pod recreation
Document findings using professional incident reports and runbooks
Technologies Used
Kubernetes
kind (Kubernetes in Docker)
kubectl
NGINX (Unprivileged)
Persistent Volumes (PV)
Persistent Volume Claims (PVC)
StorageClass
StatefulSet
Headless Service
Git & GitHub
Repository Structure
04-statefulset-pv/
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
Architecture
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
Scenario

A StatefulSet is deployed with a volumeClaimTemplate.

The PVC requests a StorageClass that does not exist.

Because Kubernetes cannot find a matching StorageClass, the PersistentVolumeClaim remains Pending, preventing the StatefulSet Pod from being scheduled.

The incident is resolved by deploying the StatefulSet with a valid StorageClass and verifying that dynamic provisioning succeeds.

Incident Timeline
Initial Deployment
Headless Service created
StatefulSet created
PVC automatically generated
PVC requests an invalid StorageClass
Dynamic provisioning fails
StatefulSet Pod remains Pending
Investigation

The following Kubernetes resources are inspected:

StatefulSet
Pod
PersistentVolumeClaim
PersistentVolume
StorageClass
Kubernetes Events
Root Cause

The StatefulSet references a StorageClass that does not exist in the cluster.

Because no storage provisioner can satisfy the request, the PVC never binds to a PersistentVolume.

Without a bound PVC, the StatefulSet Pod cannot start.

Resolution

The invalid StorageClass is replaced with the cluster's valid StorageClass.

The StatefulSet is recreated.

Kubernetes dynamically provisions a PersistentVolume.

The PVC becomes Bound.

The Pod enters the Running state.

Troubleshooting Workflow

The investigation follows a repeatable production workflow.

Verify StatefulSet status
kubectl get statefulset
Check Pod status
kubectl get pods
Inspect Pod events
kubectl describe pod stateful-web-0
Verify PersistentVolumeClaim
kubectl get pvc
kubectl describe pvc web-data-stateful-web-0
Verify available StorageClasses
kubectl get storageclass
Inspect PersistentVolumes
kubectl get pv
Review namespace events
kubectl get events --sort-by=.metadata.creationTimestamp
Validation

The incident is considered resolved when:

StatefulSet reports 1/1 Ready
Pod status is Running
PVC status is Bound
PersistentVolume is created successfully
NGINX serves content from the mounted volume
Data persists after deleting and recreating the Pod
Persistence Test

A unique marker file is written to the mounted volume.

The StatefulSet Pod is deleted.

Kubernetes automatically recreates the Pod.

The marker file remains available after recreation, demonstrating that the PersistentVolume persists independently of the Pod lifecycle.

Key Kubernetes Concepts
StatefulSet

Provides stable Pod identities and persistent storage for stateful applications.

Headless Service

Enables stable DNS names for StatefulSet Pods.

PersistentVolume (PV)

Represents physical or cloud storage available to the Kubernetes cluster.

PersistentVolumeClaim (PVC)

A request for storage made by a Pod.

StorageClass

Defines how Kubernetes dynamically provisions storage.

Common Causes of Stateful Storage Failures
Invalid StorageClass
Missing CSI Driver
Storage Provisioner unavailable
Unbound PersistentVolumeClaim
Incorrect Access Mode
Incorrect Capacity Request
Failed Volume Attachment
Failed Volume Mount
Incorrect Volume Permissions
Evidence Collected

The repository contains evidence captured during troubleshooting, including:

StatefulSet status
Pod status
PVC status
PV configuration
Cluster events
Data persistence verification
Pod recreation validation
Skills Demonstrated
Kubernetes StatefulSets
Dynamic Storage Provisioning
Persistent Volumes & Claims
StorageClasses
Headless Services
Root Cause Analysis
Incident Response
Kubernetes Troubleshooting
Production Runbook Development
Git-based Infrastructure Documentation
Lessons Learned
Stateful workloads depend on correctly configured storage resources.
A Pending PVC prevents StatefulSet Pods from starting.
Kubernetes Events provide the fastest path to identifying storage issues.
PersistentVolumes outlive Pods and preserve application data.
Storage validation should be part of every production deployment pipeline.
