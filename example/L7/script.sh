
kubectl apply -f share-emptyDir.yaml

kubectl exec -it codestar-pod -c codestar-ctn-emptydir -- /bin/sh    # alpine doesn't have bash

# Check RAM memory

df -h /vol2

echo "disk share ok" > /vol1/file2share.txt
echo "ram share ok" > /vol2/otherfile2share.txt

# Go to other ctn:

k exec -it codestar-pod -c codestar-ctn-emptydir2 -- /bin/sh

cat /vol-disk/file2share.txt
cat /vol-ram/otherfile2share.txt

# Test ram disk

dd if=/dev/urandom of=/vol-ram/largefile bs=100M count=1    # dd on alpine is max 32MB only.


# Use PV + PVC

kubectl apply -f PVC.yaml


kubectl get pv,pvc,pod

kubectl exec -it task-pv-pod -- /bin/bash

echo "This is a file created" > /usr/share/nginx/html/index.html

kubectl get pod -owide


kubectl exec -it task-pv-pod2 -- ls /usr/share/nginx/html/
kubectl exec -it task-pv-pod3 -- ls /usr/share/nginx/html/


# Apply EBS CSI driver

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.11"

# Apply EFS CSI if needed
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.4"

kubectl apply -f dynamic-pvc.yaml

# To release a PV used:

kubectl apply -f StatefulSet.yaml

# To modify statefulset, we can scale similar like replicaset
kubectl scale sts web --replicas=2

kubectl patch pv task-pv-volume03 -p '{"spec":{"claimRef": null}}'


# BACKUP WITH ETCD
# Install etcd client
sudo apt install etcd-client

# Get info like cert, key from describing the etcd pod.
kubectl describe pod etcd-...

# Export etcd 
sudo ETCDCTL_API=3 etcdctl --endpoints=https://172.31.25.221:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt  --key=/etc/kubernetes/pki/etcd/server.key snapshot save test

# Import
sudo ETCDCTL_API=3 etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt  --key=/etc/kubernetes/pki/etcd/server.key  snapshot restore test

# Stop current container in the cluster

mkdir /tmp/
mv /etc/kubernetes/manifests/*.yaml /tmp/
# Wait until it stop, check by:
sudo crictl ps 

# Replace etcd data:

mv /var/lib/etcd/member /var/lib/etcd/member.backup
mv ./default.etcd/member /var/lib/etcd


# Restart k8s cluster managing container:

mv /tmp/*.yaml /etc/kubernetes/manifests/

systemctl restart containerd # depend on CRI engine
