sudo apt-get update
sudo apt-get install docker-ce-cli docker-ce -y
# Start docker permission
sudo chmod 666 /var/run/docker.sock
sudo chmod 666 /run/containerd/containerd.sock