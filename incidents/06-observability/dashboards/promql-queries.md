# Observability Demo PromQL Queries

## Request rate

```promql
sum(rate(demo_http_requests_total{namespace="observability-demo"}[5m]))
Request rate by endpoint
sum by (endpoint) (
  rate(demo_http_requests_total{namespace="observability-demo"}[5m])
)
HTTP 5xx rate
sum(
  rate(
    demo_http_requests_total{
      namespace="observability-demo",
      status=~"5.."
    }[5m]
  )
)
HTTP 5xx percentage
100 *
sum(
  rate(
    demo_http_requests_total{
      namespace="observability-demo",
      status=~"5.."
    }[5m]
  )
)
/
clamp_min(
  sum(
    rate(
      demo_http_requests_total{
        namespace="observability-demo"
      }[5m]
    )
  ),
  0.001
)
p95 latency
histogram_quantile(
  0.95,
  sum by (le) (
    rate(
      demo_http_request_duration_seconds_bucket{
        namespace="observability-demo"
      }[5m]
    )
  )
)
Active requests
sum(
  demo_http_active_requests{
    namespace="observability-demo"
  }
)
Pod CPU in millicores
1000 *
sum by (pod) (
  rate(
    container_cpu_usage_seconds_total{
      namespace="observability-demo",
      pod=~"observability-demo-.*",
      container="application"
    }[5m]
  )
)
Pod memory
sum by (pod) (
  container_memory_working_set_bytes{
    namespace="observability-demo",
    pod=~"observability-demo-.*",
    container="application"
  }
)
Container restarts
sum by (pod) (
  kube_pod_container_status_restarts_total{
    namespace="observability-demo",
    pod=~"observability-demo-.*",
    container="application"
  }
)
Available replicas
kube_deployment_status_replicas_available{
  namespace="observability-demo",
  deployment="observability-demo"
}

