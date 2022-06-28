# Service Account

## 1. Definition

-   A service account provides an identity for processes that run in a Pod
-   Each namespace will have a different set of service account.

## 2 Script

-   Opt out automount Service Account Token with `automountServiceAccountToken: false`
-   Or even in a pod with: `spec.automountServiceAccountToken: false` (take precedence over ServiceAccount)

-   List service account of a cluster by:

```
kubectl get serviceaccounts
```

-   Create additional service account:

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: new-account-name
EOF

```

-   Get information of a service account:

```
kubectl get serviceaccounts/new-account-name -o yaml
```

-   When a service account is created, a token is also created for that account.
    The token secret will be store as a Secret in Service Account dump.

```
## ...
secrets:
  name: new-account-name-token-6w6hh
```

-   Create a service account API token manually

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: build-robot-secret
  annotations:
    kubernetes.io/service-account.name: build-robot
type: kubernetes.io/service-account-token
EOF
```

(Type must be service-account-token)

## 3. Use a specific token/secret to pull image

You can create a secret under a specific name, email with this command:

```
kubectl create secret docker-registry myregistrykey --docker-server=DUMMY_SERVER \
        --docker-username=DUMMY_USERNAME --docker-password=DUMMY_DOCKER_PASSWORD \
        --docker-email=DUMMY_DOCKER_EMAIL
```

This is a secret. Therefore, can have all command mentioned above.

### 3.1 Add secret to service account:

To add secrets into service account, just patch it with this command:

```
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}'
```

Or there's another way:

```
# Get manifest
kubectl get serviceaccounts default -o yaml > ./sa.yaml

# Remove metadata.resourceVersion

# Add imagePullSecrets.[{"name": "myregistrykeymy"}]

# And replace config for the new one
kubectl replace serviceaccount default -f ./sa.yaml
```

=> After setting imagePullSecret, every Pod created in the current namespace will have this attribute

```
kubectl run nginx --image=nginx --restart=Never
kubectl get pod nginx -o=jsonpath='{.spec.imagePullSecrets[0].name}{"\n"}'
```
