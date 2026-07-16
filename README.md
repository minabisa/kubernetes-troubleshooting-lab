# Kubernetes Troubleshooting Lab

A hands-on DevOps portfolio project that demonstrates real-world Kubernetes operations, troubleshooting, observability, and incident response. The project simulates common production issues and provides practical solutions using industry-standard tools and best practices.

---

## Project Overview

This repository contains six practical incidents designed to build experience with diagnosing, troubleshooting, and monitoring Kubernetes workloads.

Each incident includes:

* Architecture and configuration files
* Kubernetes manifests
* Step-by-step implementation
* Troubleshooting procedures
* Runbooks
* Evidence and screenshots
* Documentation

---

## Project Structure

```text
kubernetes-troubleshooting-lab/
├── 01-ImagePullBackOff/
├── 02-CrashLoopBackOff/
├── 03-Pods-Not-Schedulable/
├── 04-StatefulSet-Persistent-Volumes/
├── 05-NetworkPolicy/
└── 06-Observability/
```

---

## Incidents

### 01 – ImagePullBackOff

**Objective:** Diagnose and resolve image pull failures.

**Topics Covered**

* Container registries
* Image tags
* Private registries
* imagePullSecrets
* Deployment troubleshooting

---

### 02 – CrashLoopBackOff

**Objective:** Investigate application startup failures.

**Topics Covered**

* Container logs
* Readiness probes
* Liveness probes
* Startup probes
* Resource limits
* Root cause analysis

---

### 03 – Pods Not Schedulable

**Objective:** Troubleshoot Kubernetes scheduling failures.

**Topics Covered**

* Resource requests and limits
* Node taints and tolerations
* Node selectors
* Affinity and anti-affinity
* Scheduler diagnostics

---

### 04 – StatefulSet & Persistent Volumes

**Objective:** Deploy and troubleshoot stateful workloads.

**Topics Covered**

* StatefulSets
* PersistentVolumes
* PersistentVolumeClaims
* StorageClasses
* Data persistence

---

### 05 – NetworkPolicy

**Objective:** Secure communication between Kubernetes workloads.

**Topics Covered**

* Ingress policies
* Egress policies
* Namespace isolation
* Pod communication
* Zero Trust networking

---

### 06 – Observability

**Objective:** Build a complete Kubernetes monitoring platform.

**Technologies**

* Prometheus
* Grafana
* Alertmanager
* Prometheus Operator
* ServiceMonitor
* PrometheusRule
* Python
* Docker
* Helm

**Features**

* Custom application metrics
* Grafana dashboards
* Prometheus alerting
* Alertmanager routing
* Traffic simulation
* Incident monitoring

---

## Technologies Used

* Kubernetes
* Docker
* Helm
* Prometheus
* Grafana
* Alertmanager
* Python (Flask)
* Git
* Linux
* Bash

---

## Skills Demonstrated

* Kubernetes Administration
* Troubleshooting Production Issues
* Container Debugging
* Persistent Storage Management
* Kubernetes Networking
* Monitoring & Observability
* Prometheus & PromQL
* Grafana Dashboard Design
* Alerting & Incident Response
* Docker Image Management
* Helm Package Management
* Infrastructure as Code
* Technical Documentation

---

## Learning Outcomes

This project demonstrates the ability to:

* Diagnose common Kubernetes failures.
* Build a production-style observability platform.
* Configure monitoring and alerting for Kubernetes applications.
* Create reusable dashboards and runbooks.
* Apply structured troubleshooting techniques.
* Document solutions using engineering best practices.

---

## Future Enhancements

* GitOps with Argo CD
* CI/CD using Jenkins or GitHub Actions
* AWS EKS deployment
* HashiCorp Vault integration
* OpenTelemetry tracing
* Loki centralized logging
* Slack and Microsoft Teams alert notifications

---

## Author

**Mina Bisa**

DevOps Engineer | AWS | Kubernetes | Terraform | Docker | Jenkins | Prometheus | Grafana

---

## License

This repository is intended for learning, portfolio, and demonstration purposes.

