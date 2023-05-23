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

apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update
apt install -y containerd.io

# Config containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd


# Step 3: Add kubernetes repo

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository -y "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# jammy is work only for ubuntu 22

# Step 4: Install kubernetes components (specific version)

apt update
apt install -y kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00
apt-mark hold kubelet kubeadm kubectl

# Step 5: CREATE CLUSTER
kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.24.0

# Step 6: Config access cluster as root

# Note: This line only work if you run the whole .sh file. 
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /root/.bashrc
source /root/.bashrc

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# If you want to copy the code and run, please use:
export KUBECONFIG=/etc/kubernetes/admin.conf

# Step 7: Config crictl for debugging:
echo """
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
""" | tee /etc/crictl.yaml


# Step 8: For node which start to receive Ready, you will need to install CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml


# Step 9: Get the join command
cat /var/log/cloud-init-output.log | grep 'kubeadm join' -A1 > /root/join_command.sh


#### STEP BELOW WILL ONLY NEEDED FOR RANCHER
#
# # Step 10: Install helm if necessary
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh

# # Step 11: Install rancher
# helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
# kubectl create namespace cattle-system

# # Step 12: Install cert-manager

# # If you have installed the CRDs manually instead of with the `--set installCRDs=true` option added to your Helm install command, you should upgrade your CRD resources before upgrading the Helm chart:
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml

# # Add the Jetstack Helm repository
# helm repo add jetstack https://charts.jetstack.io

# # Update your local Helm chart repository cache
# helm repo update

# # Install the cert-manager Helm chart
# helm install cert-manager jetstack/cert-manager \
#   --namespace cert-manager \
#   --create-namespace \
#   --version v1.7.1

#   # Install rancher:

#   helm install rancher rancher-latest/rancher \
#   --namespace cattle-system \
#   --set hostname=rancher.my.org \
#   --set bootstrapPassword=admin