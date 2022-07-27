curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh




# To search from Artifact Hub https://artifacthub.io/, you can try
# helm search hub <filter>
helm search hub wordpress


# Add/remove repo for searching  in the future
helm repo add brigade https://brigadecore.github.io/charts
helm repo remove brigade

# Search for repository
# Search for chart in repo
# helm search repo <filter> 
helm search repo kash

helm search repo wordpress

helm repo add brigade https://brigadecore.github.io/charts
helm install testchart bitnami/wordpress

# WIP
kubectl apply -f pv-cluster.yaml