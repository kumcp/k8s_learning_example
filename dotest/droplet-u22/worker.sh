#!/bin/bash


# Step 1: Turn off swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Step 2: Config bridge
modprobe overlay
modprobe br_netfilter

echo """
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
""" > /etc/sysctl.d/kubernetes.conf
sysctl --system


# Step 3: Install containerd

sudo apt-get install containerd -y




# Step 4: Add kubernetes repo

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl


sudo mkdir /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


# jammy is work only for ubuntu 22

# Install kubernetes components



# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet


# Config containerd

# Config containerd
sudo mkdir /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl restart kubelet


# Step 5: Config access cluster as root
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /root/.bashrc
source /root/.bashrc

export KUBECONFIG=/etc/kubernetes/admin.conf

# Step 6: Config crictl for debugging:
echo """
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
""" | tee /etc/crictl.yaml

# Step 7: Join cluster
# Copy join cluster command here.
#
# It should start with kubeadm join ...


