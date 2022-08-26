# Install a helm repo chart with values:

helm install <release-name> <path>

helm install myrelease ./

# Check template

helm template myrepo ./
helm template myrepo ./ --debug


#List release

helm list

helm status test

helm create codestar-repo

helm uninstall <release-name>

kubectl get configmap

# Upload ECR

aws ecr get-login-password --region ap-southeast-1 | helm registry login --username AWS --password-stdin 103251686303.dkr.ecr.ap-southeast-1.amazonaws.com

helm package ./chart-repoX1/

helm push labX1-0.11.0.tgz oci://103251686303.dkr.ecr.ap-southeast-1.amazonaws.com/


# Install from ECR
helm install ecr-chart-demo oci://103251686303.dkr.ecr.ap-southeast-1.amazonaws.com/lab1 --version 0.11.0
