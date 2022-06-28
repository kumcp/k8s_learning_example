# Probes

kubelet uses probes to know the timing to do some actions

-   kubelet uses **liveness** probes to know _when to restart the container_
-   kubelet uses **readiness** probes when a container is _ready to accept traffic_
-   kubelet uses **startup** probes when _a container has started_

## 1. Config

Probe configurations are defined in Pod spec `spec.containers.livenessProbe`:

Pod spec:

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

In `livenessProbe`, there are several configurations:

-   `initialDelaySeconds`: The time period to wait at initial
-   `periodSeconds`: The time to wait interval
-   `exec.command`: The command will be execute each period of time. If it return 0 -> healther, else -> failed => Kill container and restart
