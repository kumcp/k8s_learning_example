## What is prometheus ?

- Prometheus is a tool for monitoring system's resources
- Metric types

## 2. Metric type

- Counter: cumulative values, the only increase values
- Gauge: Values which can go up and down
- Histogram: Track the size of events
- Summary:

## 3. Job:

This is the config for collecting metrics from a collection of endpoints

## 4. Kubernetes Operators

- This is a software extensions to k8s
- Handle by using k8s API
- Built on Custom Resources (CRs) implemented by Custom Resource Definitions (CRDs) and custom controllers
- Custom controllers observed CR and take actions to adjust cluster to desired state

## 4. Prometheus CRDs

### 4.1 ServiceMonitor & PodMonitor

ServiceMonitor and PodMonitor are 2 CRDs created by Prometheus

They are managed by Prometheus kind. We can see detail by

```
kubectl edit prometheus <prom-name>
```

ServiceMonitor has the spec like this:

```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: codestar-monitor
  labels:
    name: codestar-monitor
    release: prometheus-release
spec:
  selector:
    matchLabels:
      app: codestar
  endpoints:
    - port: web

```

- This `ServiceMonitor` is for monitoring a Service, and PodMonitor is for monitoring a Pod.
- The management bond is created by selector (similar to Deployment) and endpoints (when we want to monitor a specific endpoints)
- `ServiceMonitor` will have a label defined in Prometheus object
