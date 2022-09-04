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
