## 1. Definition

- A CICD Tool for deploying
- Jenkins can be run outside of a cluster or inside a cluster, depend on how you structure it

## 2. Jenkins in a cluster

- Jenkins in a cluster (Jenkins-ctn) create others containers/Pods to do their job.
- In order to do stuff in a cluster, it's necessary to create an ServiceAccount which provide appropriate permissions for working in a cluster.
- Jenkins can manage multiple cluster, base on the configuration. For a k8s cluster, you will need to add cacert and kubernetes API which point to the clusters, then Jenkins can make amends to the cluster.

- More detail about using with k8s plugin, see [here](https://plugins.jenkins.io/kubernetes/)

## 3. Pipeline Syntax
