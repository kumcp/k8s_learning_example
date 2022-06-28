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
        Pod 1   <------+   |   \
    label: key=value     Pod 2 <--------+    +-----> Pod 3
    port: X             label: key=value            label: key=value
                        port: X                     port: X

```

## 3. Type

There are 4 types of Service:

### 3.1 ClusterIP

### 3.2
