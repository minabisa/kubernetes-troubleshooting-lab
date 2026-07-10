# CrashLoopBackOff Troubleshooting Runbook

## Purpose

This runbook provides a repeatable procedure for diagnosing Kubernetes
containers that start, terminate, and restart repeatedly.

## Meaning

CrashLoopBackOff indicates that a container has failed repeatedly and
Kubernetes is applying a delay before attempting another restart.

CrashLoopBackOff is not the root cause. It is a symptom of an underlying
container or application failure.

## Common causes

1. Application startup failure
2. Missing environment variables
3. Incorrect command or arguments
4. Missing configuration files
5. Incorrect Secrets or ConfigMaps
6. Dependency connection failure
7. Failed liveness probe
8. Out-of-memory termination
9. File permission failure
10. Application code defect

## Investigation procedure

### 1. Identify affected Pods

```bash
kubectl get pods -n <namespace>
2. Inspect Pod status and restart count
kubectl get pod <pod-name> \
  -n <namespace> \
  -o wide
3. Describe the Pod
kubectl describe pod <pod-name> \
  -n <namespace>

Review:

Current container state
Previous container state
Exit code
Restart count
Pod conditions
Events
4. Read current logs
kubectl logs <pod-name> \
  -n <namespace>

For a multi-container Pod:

kubectl logs <pod-name> \
  -n <namespace> \
  -c <container-name>
5. Read previous-container logs
kubectl logs <pod-name> \
  -n <namespace> \
  --previous

For a multi-container Pod:

kubectl logs <pod-name> \
  -n <namespace> \
  -c <container-name> \
  --previous
6. Inspect exit code and termination reason
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.status.containerStatuses[*].lastState.terminated}'

Common exit codes include:

0: Successful process completion
1: General application failure
126: Command found but cannot be executed
127: Command not found
137: Process received SIGKILL, often associated with memory termination
143: Process received SIGTERM

Exit codes must be interpreted together with logs, Pod status, events, and
resource information.

7. Review application configuration
kubectl get deployment <deployment-name> \
  -n <namespace> \
  -o yaml

Check:

image
command
args
env
envFrom
ConfigMap references
Secret references
volume mounts
health probes
resource limits
8. Inspect events
kubectl get events \
  -n <namespace> \
  --sort-by=.metadata.creationTimestamp
9. Check resource termination
kubectl describe pod <pod-name> \
  -n <namespace>

Look for:

Reason: OOMKilled
Exit Code: 137
10. Apply the correction

Correct the application configuration, image, command, resource allocation,
dependency configuration, or health probes.

11. Verify recovery
kubectl rollout status \
  deployment/<deployment-name> \
  -n <namespace>
kubectl get pods \
  -n <namespace>
kubectl logs <new-pod-name> \
  -n <namespace>

Confirm that:

Pods are Running
Containers are Ready
Restart counts are stable
Service endpoints exist
Application health checks succeed
Escalation criteria

Escalate when:

Multiple workloads begin crashing simultaneously
The incident appears related to a shared dependency
Pods are OOMKilled across multiple nodes
A production configuration or Secret is corrupted
Application logs indicate data corruption
Rollback does not restore service
Customer-facing availability is affected
