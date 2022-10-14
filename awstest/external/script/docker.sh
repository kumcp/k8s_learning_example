
# Install docker
sudo apt-get update
sudo apt-get install docker-ce-cli docker-ce -y
# Start docker permission
sudo chmod 666 /var/run/docker.sock
sudo chmod 666 /run/containerd/containerd.sock

# Install cri docker service/socket
# https://www.mirantis.com/blog/how-to-install-cri-dockerd-and-migrate-nodes-from-dockershim/


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

# NOTE: You will need to run init/join command with flag --cri-socket=unix:///var/run/cri-dockerd.sock


# unix:///var/run/cri-dockerd.sock
# KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.8"

# sudo sed -ie 's+unix:///var/run/containerd/containerd.sock+unix:///var/run/cri-dockerd.sock+' /var/lib/kubelet/kubeadm-flags.env 
# KUBECONFIG=/etc/kubernetes/admin.conf kubectl edit no <NODE>