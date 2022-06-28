# Storage Class

## 1. Definition

-   Is a description of a Class
-   Can map to quality-of-service levels, buckup policies, arbitrary policy

## 2. Spec

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - debug
volumeBindingMode: Immediate
```

Require: `provisioner`, `parameters`, `reclaimPolicy`

-   Provisioner:

There are lots of provisioner can be used, related to some cloud providers:

-   `AWSElasticBlockStore`
-   `AzureFile`
-   `AzureDisk`
-   `NFS`
-   `Local`

This work like an API to cloud provider
