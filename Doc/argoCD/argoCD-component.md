## 1. API Server

The API server is a gRPC/REST server which exposes the API consumed by the Web UI, CLI, and CI/CD systems. It has the following responsibilities:

- application management and status reporting
- invoking of application operations (e.g. sync, rollback, user-defined actions)
- repository and cluster credential management (stored as K8s secrets)
- authentication and auth delegation to external identity providers
- RBAC enforcement
- listener/forwarder for Git webhook events

* End user can access ArgoCD via API Server using Web UI or ArgoCD CLI

## 2. Argocd CLI

### 2.1 Login to ArgoCD Server

ArgoCD CLI can login to any ArgoCD Server.

Before login to Argocd Server, we need to get credentials at the server host:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

```

- Login to Argocd Server using CLI, will need:

```
argocd login <server-address> --name <server-name>
```

`<server-address>` is domain or IP address of the host where ArgoCD Server is serving
`<server-name>` is the name of the context

### 2.2 Context

After login to a Server, ArgoCD CLI will store the credentials in a context (which means each Server). You can list up all ArgoCD CLI by:

```
argocd context

# Choose a context
argocd context <context-name>

# Delete with
argocd context <context-name> --delete
```

## 3. Web UI

## 4. Repository

To start working with a repository, we will need to config repository. We can use both Web UI and ArgoCD CLI. Whatever method, you will need to create a key pair. Create a key pair on your server (ubuntu) if you do not have it yet:

```
ssh-keygen
```

Copy the content of public key (default in /home/ubuntu/.ssh/id_rsa.pub) and paste to github deploy key of the project/ssh for codecommit/ or equivalent.

The private key will be used when you access the repo

- Argocd CLI:

```
argocd repo add <ssh-link> --ssh-private-key-path <private-key-path>

# Example with code commit
argocd repo add ssh://<SSH-ID>@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/test-repo --ssh-private-key-path /home/ubuntu/.ssh/id_rsa --insecure
# Notice: for CodeCommit, SSH Id will be created when you upload public key


# Example with github:
argocd repo add git@github.com:kumcp/k8s_learning_example.git --ssh-private-key-path /home/ubuntu/.ssh/id_rsa
```

- Web UI:
