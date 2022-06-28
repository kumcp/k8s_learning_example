## CNI - Container Network Interface

CNI is used to create a network overlay framework for k8s cluster.

You can see more [here](https://medium.com/@jain.sm/flannel-vs-calico-a-battle-of-l2-vs-l3-based-networking-5a30cd0a3ebd)

4 CNI providers are: Calico, Flannel, Canal, Weave

**Detail for these CNI providers will append here**

### 1. Apply calico into cluster

```
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

# OR

kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
```
