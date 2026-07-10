# ImagePullBackOff Troubleshooting Runbook

## Purpose

This runbook provides a repeatable procedure for diagnosing Kubernetes Pods
that are in the `ErrImagePull` or `ImagePullBackOff` state.

## Common causes

1. Incorrect image name
2. Nonexistent image tag
3. Private registry authentication failure
4. Missing imagePullSecret
5. Registry outage
6. Node DNS or network failure
7. Registry rate limiting
8. Invalid container registry certificate

## Investigation procedure

### 1. Identify affected Pods

```bash
kubectl get pods -A
2. Describe the affected Pod
kubectl describe pod <pod-name> -n <namespace>

Review the Events section for the exact registry error.

3. Check the configured image
kubectl get pod <pod-name> \
  -n <namespace> \
  -o jsonpath='{.spec.containers[*].image}'
4. Inspect recent events
kubectl get events \
  -n <namespace> \
  --sort-by=.metadata.creationTimestamp
5. Validate registry credentials
kubectl get serviceaccount <service-account> \
  -n <namespace> \
  -o yaml
kubectl get secret -n <namespace>

Do not print or commit decoded production credentials.

6. Validate node connectivity

Check whether the node can resolve and reach the image registry.

7. Apply the correction

Correct the image name, tag, registry URL, or imagePullSecret.

8. Verify recovery
kubectl rollout status deployment/<deployment-name> \
  -n <namespace>
kubectl get pods -n <namespace>
Escalation criteria

Escalate the incident when:

Multiple applications cannot pull images
The registry is unavailable
Authentication failures affect multiple namespaces
Nodes cannot resolve or reach the registry
A suspected registry security incident exists
