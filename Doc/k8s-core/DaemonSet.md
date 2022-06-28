# DaemonSet

## 1. Definition

-   Contain a Pod
-   Ensure all node will have this pods
-   If a node added to the cluster, this Pod will be created on the new node
-   Delete a DaemonSet will clean all Pod it created

*   Use-case

-   Running cluster storage daemon
-   Log collections on all nodes
-   Node monitoring on all nodes

## 2. Spec

An example of DaemonSet spec:

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    <pod-spec>
```
