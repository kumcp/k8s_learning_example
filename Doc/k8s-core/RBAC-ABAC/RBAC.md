# Role and ClusterRole

## 1. Definition

-   Role is a set of permissions and additive (no deny rule)
-   Role set permission in a namespace
-   ClusterRole set permission in a non namespaced resource (Node, PV, ...)
-   ClusterRole can:

1. define permissions on namespaced resources and be granted within individual namespace(s)
2. define permissions on namespaced resources and be granted across all namespaces
3. define permissions on cluster-scoped resources

## 2. Spec

Role example:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

ClusterRole example:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]

```

## 3. RoleBinding & ClusterBinding

-   RoleBinding is used to grant User to Role or ClusterRole

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
                        # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role            #this must be Role or ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

-   ClusterRoleBinding is used to grant User to ClusterRole which affect the whole cluster

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: Group       # This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
  name: manager     # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

## 4. Resources

Role can set permissions to some specific resources:

```

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]     # <--Allow get and list pods and pods/log
  verbs: ["get", "list"]
```

Example for access resource ConfigMap:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: configmap-updater
rules:
- apiGroups: [""]
            # at the HTTP level, the name of the resource for accessing ConfigMap objects is "configmaps"
  resources: ["configmaps"]
  resourceNames: ["my-configmap"]
  verbs: ["update", "get"]
```

Example or HTTP:

```
rules:
- nonResourceURLs: ["/healthz", "/healthz/*"] # '*' in a nonResourceURL is a suffix glob match
  verbs: ["get", "post"]
```

## 5. Test a role:

To test a role and binding, you can do something like this:

```
kubectl auth can-i -h # examples
```

Ex:

```
kubectl -n project-hamster auth can-i create secret --as system:serviceaccount:project-hamster:processor

```
