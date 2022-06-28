# Namespace

## 1. Definition

-   Namespace is a group of isolating components
-   Namespace is used for divide cluster resources between multiple users
-   k8s start with 4 initial namespace: `default`, `kube-node-lease`, `kube-public`, `kube-system`

## 2. Command

```
kubectl get ns
kubectl create ns dev
kubectl describe ns dev
kubectl edit ns dev
```

-   Get list namespace:

```
kubectl get namespace
```

-   Set namespace for subsequence commands:

```
kubectl config set-context --current --namespace=<ns-name>

# Validate
kubectl config view --minify | grep namespace:
```

## 3. Namespace & DNS

When a namespace is created, a DNS entry is also created coresponding with name:
`<service-name>.<namespace-name>.svc.cluster.local`

Container only uses `service-name` -> resolve service local to namespace

## 4. Object not in namespace

-   Not all objects are in a namespace
-   Namespace resource are not in a namespace (no sub-namespace)
-   Low level resource such as **node**, and **persistantVolumes** are not in any namespace

```
# See resource in a namespace
kubectl api-resources --namespaced=true

# See resource not in a namespace
kubectl api-resources --namespaced=false
```

## 5. Immutable label:

All namespaces will have an immutable label: `kubernetes.io/metadata.name` and have the value is the name of the namespace
