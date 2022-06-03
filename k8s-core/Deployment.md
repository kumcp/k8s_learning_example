# Deployment

## 1. Definition

-   Deployment is a declarative update for **Pods** or **ReplicaSet**.
-   Describe a desired state and Deployment Controller change the actual state to desired state

## 2. Spec format

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

This Deployment create a ReplicaSet of 3 nginx pods

-   `.spec.selector` indicates that Deployment will find Pods with these labels to match
-   `.spec.template.metadata.labels` is the labels of the Pods defined in Deployment
-   `.spec.template` is pod spec

## 3. Script

-   Get all deployment

```
kubectl get deployments
```

-   See deployment rollout status:

```
kubectl rollout status deployment/<deployment-name>
```

-   See rollout history

```
kubectl rollout -h
kubectl rollout history deploy <deployment-name>
```
