git clone https://github.com/kubernetes-sigs/metrics-server.git

cd metrics-server/deploy/kubernetes


# Install
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

