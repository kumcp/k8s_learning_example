sudo kubeadm init --ignore-preflight-errors=NumCPU,Mem --v=5 --pod-network-cidr=192.168.0.0/16

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

# if pod network in "kubeadm init" is not =192.168.0.0/16, then edit downloaded custom-resources.yaml file accordingly (edit cidr= entry, default is 192.168.0.0/16)
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
# curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O
# kubectl create -f custom-resources.yaml 
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml


# Note for someone need to read this:
# Calico 3.25 is using okay for now to propagate pods communication between nodes
# Calico 3.26+ cannot access pods from other nodes. Investigating now.


##### UPLOAD JOIN COMMAND INTO SSM PARAMETER

aws ssm put-parameter --name=${join_command}  --type=String --value="$(cat /var/log/cloud-init-output.log | grep 'kubeadm join' -A1)" --overwrite
aws ssm put-parameter --name=number_of_workers  --type=String --value=0 --overwrite