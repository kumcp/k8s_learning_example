# RBAC

## 1. RBAC:

```
kube-apiserver --authorization-mode=Example,RBAC --other-options --more-options

```

## 1. ABAC:

```
kube-apiserver --authorization-mode=ABAC --other-options --more-options --authorization-policy-file=SOME_FILENAME

```

ABAC defines a file containing policy in each line:

-   alice can do anything in any namespace to any resource type
-   kubelet can read all pods in any namespace

```
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "alice", "namespace": "*", "resource": "*", "apiGroup": "*"}}
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "kubelet", "namespace": "*", "resource": "pods", "readonly": true}}
```

Each service account will have a resource name:

```
system:serviceaccount:<namespace>:<serviceaccountname>
```

The default service account in a namespace will have the permission from:

```
system:serviceaccount:<namespace>:default
```

API server will need to restart
