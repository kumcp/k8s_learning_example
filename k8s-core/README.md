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

## 2. Common Script

### 2.1 Check current configuration

This is the script to check the current pod

```
kubectl run <pod-name> --image=<image-name> --dry-run=client -o yaml
```

`--dry-run=client`: This script will not create the real pod
`-o yaml`: Get the output yaml. There are several output: json|yaml|name|...

Use `kubectl run --help` for more detail
