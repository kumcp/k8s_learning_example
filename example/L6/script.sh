

kubectl taint nodes <node-name> fe=notnginx:NoSchedule

kubectl apply -f Deployment.yaml

kubectl apply -f Deployment-tolerations.yaml

kubectl apply -f ConfigMap-simple.yaml

kubectl exec -it configmap-demo-pod -- /bin/sh

# --- CREATE SECRET

echo -n 'admin' > ./username.txt
echo -n '12345678' > ./password.txt

kubectl create secret generic db-credential \
  --from-file=username=./username.txt \
  --from-file=password=./password.txt

kubectl create secret generic db-credential \
  --from-literal=username=user1 \
  --from-literal=password='123456!!'

kubectl get secret db-user-pass

kubectl get secret db-user-pass -o json

kubectl get secret db-user-pass -o jsonpath='{.data.username}' | base64 --decode


kubectl apply -f Secret.yaml


# Test
kubectl exec -it mypod -- /bin/bash

kubuectl edit secrets db-user-pass

# username: dXNlcjE=

# Role and Role Binding

kubectl create ns testns

kubectl exec -it nginx1 -n testns -- /bin/bash

# Add new user in ec2 (optional)

sudo adduser newacc --disabled-password

sudo su - newacc
mkdir .ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Create private key
openssl genrsa -out newacc.key 2048

# Without Group
openssl req -new -key newacc.key \
  -out newacc.csr \
  -subj "/CN=newacc"

# With a Group where $group is the group name
openssl req -new -key newacc.key \
  -out newacc.csr \
  -subj "/CN=newacc/O=$group"

#If the user has multiple groups
openssl req -new -key newacc.key \
  -out newacc.csr \
  -subj "/CN=newacc/O=$group1/O=$group2/O=$group3"

# Register for 500 days, Remember to run in sudo
openssl x509 -req -in newacc.csr \  
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out newacc.crt -days 500

mkdir .certs && mv newacc.crt newacc.key .certs
kubectl config set-credentials newacc \
  --client-certificate=/home/newacc/.certs/newacc.crt \
  --client-key=/home/newacc/.certs/newacc.key

kubectl config set-context newacc-context \
  --cluster=kubernetes --user=newacc

