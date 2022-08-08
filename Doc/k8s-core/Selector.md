# Selector

In k8s, you can select a node to be installed, and an app to be install on a specific nodes.
In k8s, we have several terms: labels, selectors, taints, tolerations.

## 1. Label

Labels are key/value pairs attached to an object and defined in metadata, which can be used to select later:

A similar definition of label is Annotations, which are also key/value pairs but they are not used to select:

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pod1
    key: value      # Whatever key/value pairs
  annotations:
    key1: value1
    key2: value2    # Whatever key/value pairs
  name: pod1
spec:
  ...
```

## 2. Selector

### 2.1 Node selector

Node selector is the common case of using labels.

-   We can see all labels attached to nodes by:

```
kubectl get nodes --show-labels.
```

-   Attach a new label to a node:

```
kubectl label nodes <your-node-name> <label>

# Ex:
kubectl label nodes node1-worker env=test
```

-   Specify a pod to run on a node will `nodeSelector`:

```
apiVersion: v1
kind: Pod
metadata:
  name: cuda-test
spec:
  containers:
    - name: cuda-test
      image: "image-random"
  nodeSelector:
    env: test           # Only put this pod on node with env=test label
```

### 2.2 Selector

-   Service and ReplicationController have the spec which includes `selector`:

```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

-   Set-based resources such as Job, Deployment, ReplicaSet, and DaemonSet can also use:

```
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - {key: tier, operator: In, values: [cache]}
    - {key: environment, operator: NotIn, values: [dev]}
```

Conditions are ANDed, Which will select Object with all label matched: `component=redis,tier=cache,environment=notdev`

## 3. Node Affinity

Node affinity basically has the same purpose as Label and nodeSelector. But in some cases, we will need to defined a soft rule or preferred rule, so that Scheduler are not restricted to schedule when there is no matching Node.

There are 2 options for node affinity:

-   `requiredDuringSchedulingIgnoredDuringExecution`
-   `preferredDuringSchedulingIgnoredDuringExecution`

```
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/os
            operator: In
            values:
            - linux
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

## 4. Inter-pod affinity and anti-affinity

When you want to defined a rule to deploy on a node, based on the pod which have aready run in that node, instead of Node labels.
Similar to NodeAffinity, PodAffinity and podAntiAffinity has:

-   requiredDuringSchedulingIgnoredDuringExecution
-   preferredDuringSchedulingIgnoredDuringExecution

```
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: topology.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: topology.kubernetes.io/zone
```

`podAffinity` and `podAntiyAffinity` will need to have `topologyKey`

## 5. Taint and tolerations

**Taints** are a type of mark on a node, that you want to **avoid pods to be schedules on Nodes** with these taints.

**Tolerations** are a type of mark on a pod, that you want to **allow pods to schedule on Nodes with matching taints**.

(Note: Tolerations does not assure the pod will be scheduled on a node, to do that, you need label and selectors)

-   Add a taint to a node by:

```
kubectl taint nodes node1 key1=value1:NoSchedule
```

-   Remove a taint above by:

```
kubectl taint nodes node1 key1=value1:NoSchedule-
```

```
node-role.kubernetes.io/control-plane:NoSchedule
node-role.kubernetes.io/master:NoSchedule
node.kubernetes.io/not-ready:NoSchedule
```

-   There are several type of Taints:

*   `NoSchedule`: Pod without Tolerations will not be scheduled on this Node
*   `PreferNoSchedule`: Pod without Tolerations will try to avoid being scheduled on this Node
*   `NoExecute`: Pod without Tolerations will be evicted immediately and not be scheduled on this Node

-   Use tolerances in a Pod spec to except that pod from taint

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoExecute"             # Effect when a taint is added to a node which is currently running the pod
    tolerationSeconds: 3600
```

## 6. Related concepts

### 3.1 Cordon a node

Mark a node as unschedulable. The current pods can continue to host the pod, but cannot accept
new pods

You may get the pod to stuck in Pending status because the node had untolerated taint

You can untaint it by:

```

```
