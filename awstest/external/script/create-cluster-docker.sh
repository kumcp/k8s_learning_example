
cd /tmp
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket # This require docker to be installed successfully


# Install cri-docker (new)
# Related: https://computingforgeeks.com/install-mirantis-cri-dockerd-as-docker-engine-shim-for-kubernetes/

VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
cd /tmp
# Use $$ for escaping $ character in template file
wget https://github.com/Mirantis/cri-dockerd/releases/download/v$${VER}/cri-dockerd-$${VER}.amd64.tgz
tar xvf cri-dockerd-$${VER}.amd64.tgz
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/

sudo service cri-docker start





sudo kubeadm init --ignore-preflight-errors=NumCPU,Mem --v=5 --cri-socket=unix:///var/run/cri-dockerd.sock --node-name master

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
# kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
# curl https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml -O
# kubectl create -f custom-resources.yaml
# curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
# kubectl apply -f calico.yaml
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml



# Run as root
#  export KUBECONFIG=/etc/kubernetes/admin.conf

# Run as regular usesr
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config


##### UPLOAD JOIN COMMAND INTO SSM PARAMETER

aws ssm put-parameter --name=join_command  --type=String --value="$(cat /var/log/cloud-init-output.log | grep 'kubeadm join' -A1)" --overwrite