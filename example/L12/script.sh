

# Create a separate namespace
kubectl create ns jenkins

# Add jenkins repo
helm repo add jenkinsci https://charts.jenkins.io

helm repo update

# Download jenkins (current ver 4.2.1)
helm pull jenkinsci/jenkins --untar

# serviceType -> change to NodePort
# storageClass: ebs-sc
# serviceAccount: create: false (created above)
# name: jenkins
# installPlugins: ?


helm install jenkins -n jenkins ./jenkins/

# Get password

kubectl get secret -n jenkins jenkins -o jsonpath={.data.jenkins-admin-password} | base64 --decode

# Get port
kubectl get -n jenkins -o jsonpath={.spec.ports[0].nodePort} services jenkins

# Get host


# Setup CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.11"

kubectl apply -f sa.yaml

# Login as admin/<pass from previous step>

# Config
Manage Jenkins -> Configures cloud -> 