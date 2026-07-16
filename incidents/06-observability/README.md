# Observability with Prometheus, Grafana & Alertmanager

## Project Overview

This project demonstrates how to implement a production-style observability stack for Kubernetes applications using **Prometheus**, **Grafana**, **Alertmanager**, and the **Prometheus Operator**.

A custom Python application exposes Prometheus metrics, which are automatically discovered through a `ServiceMonitor`. Metrics are visualized in Grafana dashboards and monitored with Prometheus alerting rules. Alertmanager manages alert routing and lifecycle, providing a complete monitoring workflow similar to a real-world production environment.

---

## Architecture

```
Python Application
        │
        ▼
 /metrics Endpoint
        │
        ▼
 Service
        │
        ▼
 ServiceMonitor
        │
        ▼
 Prometheus
        │
   ┌────┴────┐
   │         │
   ▼         ▼
Grafana   Alertmanager
```

---

## Technologies Used

* Kubernetes
* Prometheus
* Grafana
* Alertmanager
* Prometheus Operator
* ServiceMonitor
* PrometheusRule
* Python (Flask)
* Docker
* Helm
* Git

---

## Project Structure

```
06-observability/
├── alerts/
│   ├── application-alerts.yaml
│   └── README.md
├── alertmanager/
├── app/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── src/
│       ├── app.py
│       ├── Dockerfile
│       └── requirements.txt
├── dashboards/
│   ├── observability-demo.json
│   └── README.md
├── grafana/
├── prometheus/
│   ├── servicemonitor.yaml
│   └── values.yaml
├── scripts/
├── evidence/
└── screenshots/
```

---

## Features

* Custom Python application exposing Prometheus metrics
* Automatic metric discovery using ServiceMonitor
* Production-style Prometheus configuration
* Custom Grafana dashboard
* Application performance monitoring
* Kubernetes resource monitoring
* Prometheus alerting rules
* Alertmanager integration
* Traffic generation scripts
* Incident simulation
* Dashboard-as-Code
* Infrastructure stored in Git

---

## Custom Metrics

The application exports the following metrics:

| Metric                               | Description                         |
| ------------------------------------ | ----------------------------------- |
| `demo_http_requests_total`           | Total HTTP requests                 |
| `demo_http_request_duration_seconds` | Request latency histogram           |
| `demo_http_active_requests`          | Active requests                     |
| `demo_simulated_errors_total`        | Simulated HTTP errors               |
| `demo_application_info`              | Application version and environment |

---

## Grafana Dashboard

The dashboard includes:

* Request Rate
* HTTP 5xx Error Percentage
* p95 Request Latency
* Request Rate by Endpoint
* CPU Usage
* Memory Usage
* Active Requests
* Pod Restarts
* Deployment Availability
* Application Information

---

## Prometheus Alerts

The following production-style alerts are implemented:

| Alert                    | Severity |
| ------------------------ | -------- |
| Target Down              | Critical |
| No Available Replicas    | Critical |
| Replica Mismatch         | Warning  |
| High HTTP 5xx Error Rate | Warning  |
| High Request Latency     | Warning  |
| Container Restart        | Warning  |
| High CPU Usage           | Warning  |
| High Memory Usage        | Warning  |

---

## Skills Demonstrated

* Kubernetes Observability
* Monitoring and Alerting
* Prometheus Query Language (PromQL)
* Grafana Dashboard Design
* Helm Deployments
* Kubernetes Troubleshooting
* Docker Image Management
* Python Application Development
* Incident Detection
* Infrastructure as Code
* Git Version Control

---

## Learning Outcomes

Through this project I learned how to:

* Build an end-to-end observability platform for Kubernetes.
* Collect custom application metrics with Prometheus.
* Create reusable Grafana dashboards as code.
* Configure Prometheus alerting rules.
* Route and manage alerts with Alertmanager.
* Troubleshoot monitoring issues and validate metrics.
* Simulate production incidents and verify alert behavior.
* Apply monitoring best practices commonly used by DevOps and SRE teams.

---

## Future Improvements

* Slack and Microsoft Teams notifications
* Email alerting
* PagerDuty integration
* Distributed tracing with Jaeger
* OpenTelemetry instrumentation
* Loki for centralized logging
* Multi-cluster monitoring
* SLO and SLA dashboards

---

## Screenshots

Add screenshots demonstrating:

* Prometheus Targets
* Prometheus Alerts
* Grafana Dashboard
* Alertmanager UI
* Custom Metrics
* Application Dashboard
* Kubernetes Resources

---

## Author

**Mina Bisa**

DevOps Engineer | Kubernetes | AWS | Terraform | Docker | Jenkins | Prometheus | Grafana

---

## License

This project is intended for educational and portfolio purposes.

