
# Create cluster

eksctl create cluster -f sample-cluster.yaml
eksctl create cluster --node-ami=auto

# NOTE: Create public key .pub from private key .pem
ssh-keygen -y -f private_key1.pem > public_key1.pub


# Connect to cluster from EC2 instance:

aws eks --region ap-southeast-1 update-kubeconfig --name mycluster

# Check IAM identity mapping
eksctl get iamidentitymapping --cluster mycluster --region=ap-southeast-1

# Create mapping role RBAC
kubectl apply -f https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml
kubectl apply -f https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-restricted-access.yaml

# Add Identify mapping
eksctl create iamidentitymapping \
    --cluster mycluster-mng1 \
    --region=ap-southeast-1 \
    --arn arn:aws:iam::666402361323:user/accessCluster \
    --group eks-console-dashboard-full-access-group \
    --no-duplicate-arns


# To communicate with ALB, we need to provide permission
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json

aws iam create-policy \
   --policy-name AWSLoadBalancerControllerIAMPolicy \
   --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster=mycluster \
  --region=ap-southeast-1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::666402361323:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

# Install TargetGroupBinding
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"


# Install using helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=mycluster \
    --set serviceAccount.create=false \
    --set region=ap-southeast-1 \
    --set vpcId=vpc-0cbd02ece6c3df0d2 \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system


# Test FG
eksctl create fargateprofile --cluster mycluster --region ap-southeast-1 --name your-alb-sample-app --namespace game-2048

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/examples/2048/2048_full.yaml


kubectl get ingress -A


# OIDC
eksctl utils associate-iam-oidc-provider \
    --region ap-southeast-1 \
    --cluster mycluster \
    --approve