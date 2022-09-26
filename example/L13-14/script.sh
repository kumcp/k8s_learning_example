
git clone https://github.com/kumcp/task-assign-app.git

cd task-assign-app

docker build -f ./Dockerfile -t php-web:latest .
docker build -f ./deploy-helper/nginx/Dockerfile.nginx -t built-nginx:latest .



git clone https://github.com/kumcp/k8s_learning_example.git


kubectl create ns taa

# Modify dpl.yaml
# containers[0].name ->

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.11"


kubectl apply -f ./

# Setup ECR auto refresh token

kubectl create secret docker-registry regcred \
  --docker-server=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=taa

# Note that login-password will expired in 12 hours -> need to run it again


# Run migration
kubectl exec -it <pod-name> -n taa -- php artisan migrate
kubectl exec -it <pod-name> -n taa -- php artisan db:seed --class=DatabaseSeeder


# Jenkins note
# 1. Create Credentials as Service Account
# 2. Use jenkinsfile (from L12/lab1)
# 3. Config credentials ID