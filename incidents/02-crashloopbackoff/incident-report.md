# Incident Report: CrashLoopBackOff

## Incident ID

K8S-2026-002

## Severity

SEV-3

## Status

Resolved

## Environment

Local multi-node Kubernetes cluster created with kind.

## Summary

Two application Pods repeatedly failed during startup because a required
environment variable was not included in the Deployment configuration.

The application terminated with exit code 1. Kubernetes restarted each
container repeatedly and eventually placed the containers in the
CrashLoopBackOff state.

## Customer impact

The application had zero available replicas and could not serve requests.

## Detection

The incident was identified through:

```bash
kubectl get pods -l app=crashloop-demo

The Pods showed:

CrashLoopBackOff

with increasing restart counts.

Investigation

The following commands were used:

kubectl get pods -l app=crashloop-demo -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get deployment crashloop-demo -o yaml

The application logs showed:

FATAL: Required environment variable APP_MESSAGE is missing.

The previous container state showed:

Reason: Error
Exit Code: 1
Root cause

The application required the APP_MESSAGE environment variable during
startup. The Kubernetes Deployment did not provide the variable, causing the
application process to terminate immediately.

Resolution

A ConfigMap named crashloop-demo-config was created to store the required
non-sensitive configuration.

The Deployment was updated to load APP_MESSAGE from the ConfigMap.

Startup, readiness, and liveness probes were also added to improve application
health monitoring.

Validation

Recovery was validated using:

kubectl rollout status deployment/crashloop-demo
kubectl get pods -l app=crashloop-demo
kubectl get endpoints crashloop-demo
kubectl logs <pod-name>
curl http://localhost:8080
curl http://localhost:8080/health
curl http://localhost:8080/ready

Both replicas became Ready, application requests succeeded, and the new Pods
maintained zero restart counts.

Preventive actions
Validate required environment variables during CI.
Document mandatory application configuration.
Validate ConfigMap and Secret references before deployment.
Add deployment smoke tests.
Add startup, readiness, and liveness probes.
Alert on high container restart counts.
Alert when a Deployment has unavailable replicas.
Preserve previous-container logs through centralized logging.
Use staged deployments and automated rollback criteria.
