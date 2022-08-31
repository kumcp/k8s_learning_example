## eksctl basic

- EKS is a fully managed service for control plane of a k8s cluster
- EKSCTL is a command line interface for controling EKS.

### EKSCTL config spec

EKSCTL can be used as command with a bunch of flags like:

```
eksctl create cluster --name=cluster-2 --nodes=4 --kubeconfig=./kubeconfig.cluster-2.yaml
```

Or you can use config files (recommend) like below:

```
eksctl create cluster -f sample-cluster.yaml
```

With `sample-cluster.yaml`:

```
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: mycluster
  region: ap-southeast-1

nodeGroups:
  - name: node1
    instanceType: t2.micro
    desiredCapacity: 1
    volumeSize: 8
    ssh:
      allow: true # will use ~/.ssh/id_rsa.pub as the default ssh key
  - name: ng-2
    instanceType: t3.micro
    desiredCapacity: 2
    volumeSize: 100
    ssh:
      publicKeyPath: ~/.ssh/ec2_id_rsa.pub
```
