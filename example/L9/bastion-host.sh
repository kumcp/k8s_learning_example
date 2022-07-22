#!/bin/bash


mkdir /temp/
cd /temp/


## INSTALLING EKS CLIENT
## If you want to use other version, read this: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

echo "====== INSTALING EKS CLIENT ====== "
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
chmod +x ./kubectl

mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

echo "====== INSTALL COMPLETED ======"
echo "Your version: "
kubectl version --short --client

## INSTALL EKSCTL

echo "===== INSTALL EKSCTL ======"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
echo "===== INSTALL EKSCTL COMPLETED ======"
echo "Your version:"
eksctl version


## INSTALL AWSCLI
echo "===== INSTALL AWSCLI ======"

