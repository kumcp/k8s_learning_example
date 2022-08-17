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