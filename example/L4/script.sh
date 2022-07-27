
kubectl apply -f Job-parralellism.yaml

kubectl get job -n mynamespace

kubectl get pod | grep pi

watch kubectl get job 


kubectl get replicaset

kubectl get rs

kubectl scale rs codestar-app --replicas=2

kubectl get deploy

kubectl edit <resource-name> <deployment-name>

kubectl edit deploy nginx-deployment

kubectl set image deployment/nginx-deployment nginx=nginx:1.22.0


kubectl rollout history deployment/nginx-deployment

