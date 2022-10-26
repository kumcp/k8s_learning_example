

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
# installPlugins: 
# - kubernetes:3706.vdfb_d599579f3
# - workflow-aggregator:590.v6a_d052e5a_a_b_5
# - git:4.11.5
# - configuration-as-code:1512.vb_79d418d5fc8
# resources:
    # requests:
    #   cpu: "50m"
    #   memory: "256Mi"
    # limits:
    #   cpu: "1000m"
    #   memory: "2048Mi


helm install jenkins -n jenkins ./jenkins/

# Get password

kubectl get secret -n jenkins jenkins -o jsonpath={.data.jenkins-admin-password} | base64 --decode

# Get port
kubectl get -n jenkins -o jsonpath={.spec.ports[0].nodePort} services jenkins

# Get host


# Setup CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.11"

kubectl apply -f sa.yaml

kubectl get svc -n jenkins

# Login as admin/<pass from previous step>

# Config
# Manage Jenkins -> Credentials -> System -> Global credentials -> Create credentials
# Use Ip as in deploy with credential.jenkinsfile