# List command

## 1. Kubernetes core command

```
# List/info commands or pod

kubectl get pod [-n <namespace>]
kubectl describe pod <pod-name> [-n <namespace>]
kubectl logs pod/<pod-name> [-n <namespace>]

kubectl delete pod <pod-name>



# List command fo deployment
kubectl get deploy [-n <namespace>]
kubectl describe deploy <deployment-name> [-n <namespace>]

# Update images of a deployment
kubectl set image deployment/nginx-deployment nginx=nginx:1.22.0

# History rollout of deployment
kubectl rollout history deployment/nginx-deployment
kubectl rollout restart

kubectl rollout


# Apply
kubectl apply -f ./my-manifest.yaml            # create resource(s)
kubectl apply -f ./my1.yaml -f ./my2.yaml      # create from multiple files
kubectl apply -f ./dir                         # create resource(s) in all manifest files in dir
kubectl apply -f https://git.io/vPieo

kubectl get services --sort-by=.metadata.name


kubectl get node
kubectl describe node <node-name>

```

# 2. Project related commands

```

# Let kubernetes connect and has permission to download from private ECR

$PW=$(aws ecr get-login-password --region ap-southeast-1)
crictl pull --creds "AWS:$PW" imageURI

# Tracking a display frequently
watch kubectl get job

```
