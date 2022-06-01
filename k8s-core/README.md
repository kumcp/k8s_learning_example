# 1. Apply a k8s config file to cluster

```
kubectl apply -f [podnetwork].yaml
```

### 1.1 Describe a component

You can get more information from a node/pod/... by:

```
kubectl describe node <NODE-NAME>
kubectl describe pod <POD-NAME>
```

Want to know which node, which pod ? Use

```
kubectl get nodes
kubectl get pods
```

## 1.2 Node attracts and Pods attracts

### 1.2.1 Taint and tolerations

**Taints** are a type of mark on a node, that you want to **avoid pods to be schedules on Nodes** with
these taints.

**Tolerations** are a type of mark on a pod, that you want to **allow pods to schedule on Nodes with matching taints**.

-   Add a taint to a node by:

```
kubectl taint nodes node1 key1=value1:NoSchedule
```

-   Remove a taint above by:

```
kubectl taint nodes node1 key1=value1:NoSchedule-
```

```
node-role.kubernetes.io/control-plane:NoSchedule
node-role.kubernetes.io/master:NoSchedule
node.kubernetes.io/not-ready:NoSchedule
```

### 1.2.2 Node affinity

### 1.3 Cordon a node

Mark a node as unschedulable. The current pods can continue to host the pod, but cannot accept
new pods

You may get the pod to stuck in Pending status because the node had untolerated taint

You can untaint it by:

```

```
