1. To create a cluster (on laptop), you will need to create cluster:

```
kubeadm init --v=5
```

If you're already in a cluster, you can try:

```
kubeadm reset
```

to remove the current host from the previous cluster

You may need to setup the configuration for the cluster:

```
gcloud config set project simple-app
```
