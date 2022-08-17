#!/bin/bash

sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "============INSTALL DOCKER AND CONTAINERD=============="

sudo apt-get install containerd.io -y


# Install kubernetes

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "===========INSTALL KUBETLET & KUBEADM & KUBECTL ============="
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# This if for fixing error cgroup

sudo systemctl daemon-reload
sudo systemctl restart kubelet


# Create a kubernetes cluster

# NOTE: kubernet master node (control plane) must have at least 1,7GB RAM and 2 vCPU
# at least t3.small will work


##### INSTALL AWSCLI for saving key into SSM Parameters
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install



##### EXPERIMENTING

systemctl daemon-reload
systemctl enable --now containerd

cd ~/
wget https://github.com/opencontainers/runc/releases/download/v1.1.2/runc.amd64

install -m 755 runc.amd64 /usr/local/sbin/runc

sed -iE 's+"cri"+""+g'  /etc/containerd/config.toml

echo """
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
""" | sudo tee /etc/crictl.yaml

sudo systemctl restart containerd

sudo apt install gnupg2 software-properties-common apt-transport-https -y

#### CONFIG KERNEL IF NOT USE DOCKER
modprobe overlay
modprobe br_netfilter
echo """
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
""" > /etc/sysctl.d/kubernetes.conf
sudo sysctl --system



sudo kubeadm init --ignore-preflight-errors=NumCPU,Mem --v=5

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

# Run as root
#  export KUBECONFIG=/etc/kubernetes/admin.conf

# Install weave (is having a problem with 1 master, 2 workers)
echo "============Install weave net============"
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=1.24.3"


# Install calico CNI
# echo "============Install Calico CNI ============"
# kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
# curl https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml -O
# kubectl create -f custom-resources.yaml
# curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
# kubectl apply -f calico.yaml


# Run as reegular usesr
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config


##### UPLOAD JOIN COMMAND INTO SSM PARAMETER

aws ssm put-parameter --name=join_command  --type=String --value="$(cat /var/log/cloud-init-output.log | grep 'kubeadm join' -A1)" --overwrite

sudo apt install etcd-client -y
