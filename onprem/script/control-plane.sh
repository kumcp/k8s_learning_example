#!/bin/bash

sudo apt-get update


# Step 1: Install dependencies
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



# Step 2: Install containerd
echo "============INSTALL CONTAINERD=============="

sudo apt-get install containerd.io -y


# Step 3: Install kubernete dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 4: Install kubelet, kubeadm, kubectl
echo "===========INSTALL KUBELET & KUBEADM & KUBECTL ============="
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# This if for fixing error cgroup
sudo systemctl daemon-reload
sudo systemctl restart kubelet


# Step 5: Config CRI

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

#### Step 6: CONFIG KERNEL IF NOT USE DOCKER

modprobe overlay
modprobe br_netfilter
echo """
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
""" > /etc/sysctl.d/kubernetes.conf
sudo sysctl --system

### STEP 7 IMPORTANT: CREATE CLUSTER

sudo kubeadm init --ignore-preflight-errors=NumCPU,Mem --v=5


# Step 8: Config permission for user ubuntu. If your host using other User, please change the name
mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf


# Step 9: Install calico CNI
echo "============Install Calico CNI ============"

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
