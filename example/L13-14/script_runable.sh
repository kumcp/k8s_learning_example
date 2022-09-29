

git clone https://github.com/kumcp/task-assign-app.git

cd task-assign-app

docker build -f ./Dockerfile -t php-fpm:latest .
docker build -f ./deploy-helper/nginx/Dockerfile.nginx -t built-nginx:latest .

export ECR_IMAGE_REGION=ap-southeast-1
export AWS_ACCOUNT_ID=666402361323

aws ecr get-login-password --region $ECR_IMAGE_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$ECR_IMAGE_REGION.amazonaws.com

docker tag built-nginx:latest $AWS_ACCOUNT_ID.dkr.ecr.$ECR_IMAGE_REGION.amazonaws.com/built-nginx:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$ECR_IMAGE_REGION.amazonaws.com/built-nginx:latest

docker tag php-fpm:latest $AWS_ACCOUNT_ID.dkr.ecr.$ECR_IMAGE_REGION.amazonaws.com/php-fpm:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$ECR_IMAGE_REGION.amazonaws.com/php-fpm:latest

cd ~

git clone https://github.com/kumcp/k8s_learning_example.git

cd k8s_learning_example/example/L13-14/

kubectl create ns taa
kubectl create ns adminer

# Modify dpl.yaml
# containers[0].name ->

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.11"



# Setup ECR auto refresh token

kubectl create secret docker-registry regcred \
  --docker-server=${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_IMAGE_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=taa

kubectl apply -f ./
# Note that login-password will expired in 12 hours -> need to run it again


# Run migration
export POD_RUN=??
kubectl exec -it $POD_RUN -n taa -- php artisan migrate
kubectl exec -it $POD_RUN -n taa -- php artisan db:seed --class=DatabaseSeeder