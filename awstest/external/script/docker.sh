
# Install docker
sudo apt-get update
sudo apt-get install docker-ce-cli docker-ce -y
# Start docker permission
sudo chmod 666 /var/run/docker.sock
sudo chmod 666 /run/containerd/containerd.sock

# Install cri docker service/socket
# https://www.mirantis.com/blog/how-to-install-cri-dockerd-and-migrate-nodes-from-dockershim/


# NOTE: You will need to run init/join command with flag --cri-socket=unix:///var/run/cri-dockerd.sock


# unix:///var/run/cri-dockerd.sock
# KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.8"

# sudo sed -ie 's+unix:///var/run/containerd/containerd.sock+unix:///var/run/cri-dockerd.sock+' /var/lib/kubelet/kubeadm-flags.env 
# KUBECONFIG=/etc/kubernetes/admin.conf kubectl edit no <NODE>
