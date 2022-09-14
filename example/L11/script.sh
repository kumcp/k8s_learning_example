

kubectl create ns elk

# Create object file with CLI:
kubectl -n elk create deploy es --image=elasticsearch:8.4.1 --dry-run=client -o yaml > es.yaml

kubectl get svc -n elk

kubectl set env deployments/es ELASTICSEARCH_HOSTS=http://10.105.121.98:31688

#Note: Running on ubuntu will need to set this parameter:
# You will need to run this on all nodes
sudo sysctl -w vm.max_map_count=262144


# Modify environment
kubectl edit deployment es
# Add env: discovery.type=single-node


# Add elastic repo
helm repo add elastic https://helm.elastic.co

helm pull elastic/logstash --version 7.17.3 --untar

helm pull elastic/filebeat --version 7.17.3 --untar

helm pull elastic/elasticsearch --version 7.17.3 --untar

helm pull elastic/kibana --version 7.17.3 --untar

# Install nginx controler config 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml

kubectl apply -f PVs.yaml
#Or
kubectl apply -f https://raw.githubusercontent.com/kumcp/k8s_learning_example/master/example/L11/lab1/PVs.yaml


helm install logstash ./logstash
helm install filebeat ./filebeat
helm install elasticsearch ./elasticsearch
helm install kibana ./kibana



kubectl get pods, svc

kubectl logs pods/<podname>
kubectl describe pods/<podname>

kubectl cordon <nodename>

kubectl describe nodes