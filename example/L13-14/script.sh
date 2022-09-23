
# Setup ECR auto refresh token

kubectl create secret docker-registry regcred \
  --docker-server=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=taa

# Note that login-password will expired in 12 hours -> need to run it again

kubectl create secret docker-registry regcred \
  --docker-server=666402361323.dkr.ecr.ap-southeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=taa