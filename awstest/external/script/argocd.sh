kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# Change service to NodePort:
kubectl patch svc -n argocd argocd-server --patch '{"spec": {"type": "NodePort"}}'
