

# Create cluster with pre-config using cri-socker=cri-dockerd
sudo kubeadm init --ignore-preflight-errors=NumCPU,Mem --v=5 --cri-socket=unix:///var/run/cri-dockerd.sock --pod-network-cidr=192.168.0.0/16

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

# Install weave (is having a problem with 1 master, 2 workers)
# echo "============Install weave net============"
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=1.24.3"
# Run as root
#  export KUBECONFIG=/etc/kubernetes/admin.conf

# Install calico CNI
echo "============Install Calico CNI ============"
# if pod network in "kubeadm init" is not =192.168.0.0/16, then edit downloaded custom-resources.yaml file accordingly (edit cidr= entry, default is 192.168.0.0/16)
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
# curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
# kubectl create -f custom-resources.yaml 
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

# Run as root
#  export KUBECONFIG=/etc/kubernetes/admin.conf

# Run as regular usesr
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config


##### UPLOAD JOIN COMMAND INTO SSM PARAMETER

aws ssm put-parameter --name=${join_command}  --type=String --value="$(cat /var/log/cloud-init-output.log | grep 'kubeadm join' -A1)" --overwrite
aws ssm put-parameter --name=number_of_workers  --type=String --value=0 --overwrite