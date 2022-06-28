# Pod

## 1. Definition

## 2. Command

-   Create a temporary pod (useful for test something inside):

```
kubectl run tmp --restart=Never --rm --image=<whatever-image> -i -- <command-to-test>
```

-   `--rm`: to remove pod after test

## 3. Init Container

-   specialized containers that run before app containers in a Pod

## 4. Schedule

A pod can be schedule on a specific Node:
We can use NodeSelector:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd

```

Or nodeName:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  nodeName: foo-node # schedule pod to specific node
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

```
kubectl -n dev get pod
kubectl -n dev run mypod --image=nginx
kubectl -n dev delete pod mypod

kubectl --all-namespaces get pod
kubectl -A get pod
```
