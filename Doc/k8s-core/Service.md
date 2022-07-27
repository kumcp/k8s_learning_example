# Service

## 1. Definition

-   A layer to expose an application running on a set of Pods as a network service
-   Service can be access by DNS: `http://<service-name>.<namespace>:<port>`

## 2. Spec

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

Using selector for matching selected pod and a port

```
   +---- port
  \|/
   v       targetPort
+---------+           +-------+
| Service |  ------>  |  Pod  |
+---------+           +-------+
```

-   Be default, targetPort ~ port

-   If we name a port as a specific name, we can use it in Service

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: proxy
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
      - containerPort: 80
        name: http-web-svc

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: proxy
  ports:
  - name: name-of-service-port
    protocol: TCP
    port: 80
    targetPort: http-web-svc
```

-   Service creates Endpoints based on seletor
-   In some cases that we do not have selector, it's neccessary to have target as an IP

### 2.2 Endpoint

-   If an Endpoint has over 1000 endpoints -> that Endpoint will be taint as
    `endpoints.kubernetes.io/over-capacity: truncated`

```
apiVersion: v1
kind: Endpoints
metadata:
  # the name here should match the name of the Service
  name: my-service
subsets:
  - addresses:
      - ip: 192.0.2.42
    ports:
      - port: 9376
```

-   EndpointSlices allow distributing network Endpoint accross multiple resources
-   By default, EndpointSlice will full with 100 endpoints -> additional EndpointSlics will be created

The example above basically map to endpoint: 192.0.2.42:9376 (TCP)

```
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: example-abc
  labels:
    kubernetes.io/service-name: example
addressType: IPv4
ports:
  - name: http
    protocol: TCP
    port: 80
endpoints:
  - addresses:
      - "10.1.2.3"
    conditions:
      ready: true
    hostname: pod-1
    nodeName: node-1
    zone: us-west2-a
```

### 2.3 kube-proxy

kube-proxy is responsible for implementing a form of virtual IP for Services (not ExternalName)

`kube-proxy` has configuration use `ConfigMap` at the startup time

#### 2.3.1 User space proxy mode

```

       +--------+                 +-----------+
       | Client |                 | apiserver |
       +--------+                 +-----------+
           |                            |
           |                            |
           v                            v
+---------------------+         +--------------+
| ClusterIP(iptables) | ------> |  kube-proxy  |
+---------------------+         +--------------+
                                      / | \
                                     /  |  \
        Pod 1   <-------------------+   |   \
    label: key=value     Pod 2 <--------+    +-----> Pod 3
    port: X             label: key=value            label: key=value
                        port: X                     port: X

```

#### 2.3.2 iptables

```

       +--------+                 +-----------+
       | Client |                 | apiserver |
       +--------+                 +-----------+
           |                            |
           |                            |
           v                            v
+---------------------+         +--------------+
| ClusterIP(iptables) | ------> |  kube-proxy  |
+---------------------+         +--------------+
                                      / | \
                                     /  |  \
        Pod 1   <-------------------+   |   \
    label: key=value     Pod 2 <--------+    +-----> Pod 3
    port: X             label: key=value            label: key=value
                        port: X                     port: X

```

## 3. Type

There are 4 types of Service:

### 3.1 ClusterIP

ClusterIP is a type of Service, which is only visible by Services inside cluster

When you create a ClusterIP, other service can connect to service/pod. (Connected nodes need to open port 10250). Host environment cannot access service by clusterIP.

```
kubectl exec -it nginx -- /bin/bash

root@nginx:/# curl <clusterIP>
root@nginx:/# curl
```

In some specific cases, ClusterIP can be access through kubernetes proxy.

```
kubectl proxy --port=8080
```

Then, access through this:

```
http://localhost:8080/api/v1/proxy/namespaces/<NAMESPACE>/services/<SERVICE-NAME>:<PORT-NAME>/
```

### 3.2 NodePort

NodePort is a type of Service which is visible to outside cluster

Other service outside of cluster can access via: `<NodeIP>:<NodePort>

All Nodes in the cluster can access service via NodePort.

```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: MyApp
  ports:
      # By default and for convenience, the `targetPort` is set to the same value as the `port` field.
    - port: 80
      targetPort: 80
      # Optional field
      # By default and for convenience, the Kubernetes control plane will allocate a port from a range (default: 30000-32767)
      nodePort: 30007
```

### 3.3 LoadBalance

-   LoadBalancer is a type of Service which created follow the published cloud in Service
-   When LoadBalancer was confirmed, it provisions a actual Load Balancer
-   Traffic from external LB is directed at the Pods. The Cloud provider decides how it is load balance

```
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
  clusterIP: 10.0.171.239
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: 192.0.2.127
```
