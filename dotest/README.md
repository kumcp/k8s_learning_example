## This is the script to create cluster in Digital Ocean.

### 1. Droplet bootstrap script

There are 2 files in droplet-u22, which used for droplet ubuntu 22.10. After creating Droplets, SSH to Droplets and run these script as the role below:

```
control-plane.sh
worker.sh
```

You can run the fast script using this command:

```
git clone https://github.com/kumcp/k8s_learning_example.git
sh ./k8s_learning_example/dotest/droplet-u22/control-plane.sh
```