# Observability Demo Grafana Dashboard

This dashboard visualizes application and Kubernetes metrics for the
`observability-demo` workload.

## Panels

1. Request rate
2. HTTP 5xx error percentage
3. p95 request latency
4. Available replicas
5. Request rate by endpoint
6. Request latency percentiles
7. Pod CPU usage
8. Pod memory working set
9. HTTP 5xx error rate
10. Container restarts
11. Active requests
12. Application information

## Data sources

The dashboard uses Prometheus metrics collected through:

- A custom application ServiceMonitor
- kube-state-metrics
- Kubernetes kubelet/cAdvisor metrics

## Provisioning

The dashboard JSON is packaged inside a Kubernetes ConfigMap labeled:

```text
grafana_dashboard=1

The Grafana dashboard sidecar detects the ConfigMap and loads the dashboard
automatically.

Dashboard UID
observability-demo
Refresh interval
15 seconds

