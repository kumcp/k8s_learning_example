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
echo "===========INSTALL KUBETLET & KUBEADM & KUBECTL ============="
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


# Make sure this script run after k8s-containerd

### STEP 7 IMPORTANT: JOIN CLUSTER
# Please copy the join cluster command from control-plane and run here. If you want to modify the name, you can use flag: [--node-name worker2]
# This is an example:
# sudo kubeadm join 172.31.24.170:6443 --token cg5km7.873g3fa1055pw4ka --discovery-token-ca-cert-hash sha256:0e0343200d3a7bf573ab76b8882da4cc587e42e1479bf4681b4c3567dec8b335 --node-name worker2
