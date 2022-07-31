

kubectl expose deploy codestar-deployment

kubectl get svc

kubectl exec -it codestar-deployment-6c8b449b8f-r2g4x -- cat /etc/resolv.conf

curl 10.97.193.59

kubectl apply -f Service-with-namedPort.yaml

curl 10.99.237.160

curl localhost:30007


# Install ingress nginx controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml

# Confirm that it is running okay by:
kubectl wait --namespace ingress-nginx   --for=condition=ready pod   --selector=app.kubernetes.io/component=controller   --timeout=120s

# Create ingress point to Service (ClusterIP is okay)
kubectl create ingress demo-localhost --class=nginx   --rule="<domain-name>/*=<service-name>:80"

#NOTE: domain localdev.me point to 127.0.0.1 ~ localhost. You can use *.localdev.me to config ingress without need to
# change /etc/hosts
# Create ingress
kubectl create ingress demo-localhost --class=nginx   --rule="demo.localdev.me/*=codestar-service:80"
#  or apply ingress
kubectl apply -f Ingress.yaml

# Open port for testing
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80

curl codestar.localdev.me:8080/path1
