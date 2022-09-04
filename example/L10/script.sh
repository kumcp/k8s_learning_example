

# Add helm stable charts repo
helm repo add stable https://charts.helm.sh/stable

# Add prometheus community helm charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Search and install prmetheus chart
helm search repo prometheus-community
helm install prometheus-release prometheus-community/kube-prometheus-stack

kubectl create ns prometheus
helm install prometheus-release prometheus-community/kube-prometheus-stack --namespace prometheus

kubectl get pod

# Modify Service to Load Balancer
kubectl -n prometheus edit svc prometheus-release-kube-pr-prometheus
kubectl -n prometheus edit svc prometheus-release-grafana

# Admin account and password default: admin/prom-operator


###

# Apply deployment + service
kubectl apply -f Deploy-svc.yaml

kubectl apply -f svcmnt.yaml

# Apply ServiceMonitor
kubectl apply -f svcmnt.yaml


kubectl get prometheus

kubectl edit prometheus


kubectl exec -it codestar-deployment-7585fbdfbf-z8ths -- /bin/bash


kubectl exec -it codestar-deployment-7585fbdfbf-z8ths -- echo 'codestar_http_requests_total 5' > /usr/share/nginx/html/metrics
kubectl exec -it codestar-deployment-7585fbdfbf-z8ths -- echo 'codestar_http_requests_total 7' > /usr/share/nginx/html/metrics


# Get Secret info
kubectl get secret alertmanager-prometheus-release-kube-pr-alertmanager -o yaml

echo '...' | base64 --decode