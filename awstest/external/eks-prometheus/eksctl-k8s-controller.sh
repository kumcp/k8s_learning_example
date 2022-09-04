#!/bin/bash

sudo apt-get update

# Install kubectl (v1.23.7 newest from AWS  support)
# NOTE: This instance is the client controller only -> No need for kubelet, kubeadm, ...
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.7/2022-06-29/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin


sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

curl https://raw.githubusercontent.com/kumcp/k8s_learning_example/master/example/L9/lab3/fargate-cluster.yaml > fargate-cluster.yaml
eksctl create cluster -f fargate-cluster.yaml