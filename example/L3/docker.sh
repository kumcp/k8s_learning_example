
# Inside a Node which has Docker
sudo ctr -n k8s.io containers ls




export PW=$(aws ecr get-login-password --region ap-southeast-1)
crictl pull --creds "AWS:$PW" imageURI

