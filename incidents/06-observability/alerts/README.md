# Observability Demo Alert Rules

This directory contains Prometheus alerting rules for the observability-demo
application.

## Alert rules

| Alert | Severity | Condition |
|---|---|---|
| ObservabilityDemoTargetDown | Critical | Prometheus cannot scrape the target |
| ObservabilityDemoNoAvailableReplicas | Critical | Available replicas are below one |
| ObservabilityDemoReplicaMismatch | Warning | Desired replicas exceed available replicas |
| ObservabilityDemoHighErrorRate | Warning | HTTP 5xx percentage exceeds 10% |
| ObservabilityDemoHighLatency | Warning | p95 latency exceeds one second |
| ObservabilityDemoContainerRestart | Warning | A container restarted in the last five minutes |
| ObservabilityDemoHighCPU | Warning | Pod CPU exceeds 0.20 cores |
| ObservabilityDemoHighMemory | Warning | Working-set memory exceeds 200 MiB |

## Alert lifecycle

```text
Inactive
   |
Condition becomes true
   v
Pending
   |
Condition remains true for the configured duration
   v
Firing
   |
Condition becomes false
   v
Resolved
Lab thresholds

The thresholds and waiting periods are intentionally sensitive so the alerts
can be triggered in a local Kubernetes environment.

Production values should be based on:

Service-level objectives
Historical baselines
Capacity limits
Business impact
Expected request volume
Application behavior
