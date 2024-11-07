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

# Step 5: CREATE CLUSTER
# Flannel CNI using 10.244.0.0/16 by default. If you want to change this, modify the config in Step 8
kubeadm init --v=5 --pod-network-cidr=10.244.0.0/16

# Step 6: Config access cluster as root

# Note: This line only work if you run the whole .sh file. 
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /root/.bashrc
source /root/.bashrc



# If you want to copy the code and run, please use:
export HOME="/root"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Step 7: Config crictl for debugging:
echo """
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
""" | tee /etc/crictl.yaml


# Step 8: For node which start to receive Ready, you will need to install CNI
# Note tha Calico does not work on Digital Ocean, so use Flannel instead
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/refs/heads/master/Documentation/kube-flannel.yml
# Step 9: Get the join command
cat /var/log/cloud-init-output.log | grep 'kubeadm join' -A1 > /root/join_command.sh



