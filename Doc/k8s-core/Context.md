# Context

Context is used when you have multiple cluster to manage

Define clusters, users, contexts

## 1. Creating context

Create a file with the name: `config-exercise/config-demo` and thee content like below:

```
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
  name: development
- cluster:
  name: scratch

users:
- name: developer
- name: experimenter

contexts:
- context:
  name: dev-frontend
- context:
  name: dev-storage
- context:
  name: exp-scratch
```

In `config-exercise`, run command like these:

-   Add cluster with configuration.

```
kubectl config --kubeconfig=config-demo set-cluster development --server=https://1.2.3.4 --certificate-authority=fake-ca-file
kubectl config --kubeconfig=config-demo set-cluster scratch --server=https://5.6.7.8 --insecure-skip-tls-verify

# Remove a cluster
kubectl --kubeconfig=config-demo config unset clusters.<name>
```

-   Add user with credentials.

```
kubectl config --kubeconfig=config-demo set-credentials developer --client-certificate=fake-cert-file --client-key=fake-key-seefile
kubectl config --kubeconfig=config-demo set-credentials experimenter --username=exp --password=some-password

# Remove a cluster
kubectl --kubeconfig=config-demo config unset users.<name>
```

-   Create context with specific users and clusters:

```
kubectl config --kubeconfig=config-demo set-context dev-frontend --cluster=development --namespace=frontend --user=developer
kubectl config --kubeconfig=config-demo set-context dev-storage --cluster=development --namespace=storage --user=developer
kubectl config --kubeconfig=config-demo set-context exp-scratch --cluster=scratch --namespace=default --user=experimenter

#Remove a context
kubectl --kubeconfig=config-demo config unset contexts.<name>
```

-   Show all current information of cluster, context, users:

```
kubectl config get-contexts
kubectl config get-clusters
// ...
kubectl config view -o jsonpath="{.contexts[*].name}"

# Get current context
kubectl config current-context

# OR
cat ~/.kube/config | grep current
```
