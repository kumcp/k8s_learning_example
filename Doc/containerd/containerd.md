## 1. Containerd

- Containerd is a container manager
- Containerd is used by crictl in k8s. However, crictl is an abstract tool

## 2. Structure

- Containerd uses containderd-shim (as an integrated interface) to connect to OCI runtime (runc) for creating containers

```

+------------+
|            |      CRI API
| containerd |  <----------
|            |
+------------+
       |
       |
       v
+---------------+
|containerd-shim|   <----+
+---------------+        |
    |                    |
    v                    V
+---------+       +-----------+
|   OCI   | ----> | container |
| runtime |       +-----------+
+---------+

```

- Containerd can create, start, stop containers, pull/store images, config mounts, networking, ... But **cannot build image**. Even containerd cannot be used to build images, it is still be used by others tool to manage the container systems.

**Command line tools:**

- We can use CRI API to communicate with the containerd. But as a normal use, we can have some command-line tool to communicate with containerd:

#### ctr

This tool communicate to containerd by /run/containerd/containerd.sock. This tool is unsupport now and may not compatible with old version.

```
ctr images mount ...
ctr images remove docker.io/library/nginx:1.21

# Run a container
ctr run --rm -t docker.io/library/debian:latest cont1

ctr containers ls

# Create a task from container
ctr task start -d nginx_1

ctr task list

# Execute a task inside
ctr task exec -t --exec-id bash_1 nginx_1 bash

# Stop tasks
ctr task kill -9 nginx_1
ctr task rm -f nginx_1      # remove force

```

- Even though containerd cannot build images, it can still use images from other OCI compatible tools like docker:

```
docker build -t my-img .
docker save -o my-img.tar my-img

cri images import my-img.tar
```

#### nerdctl

- Similar to ctr, `nerdctl` communicate to containerd using containerd.sock. But nerdctl also provide some feature:

* Image building with `nerdctl build`
* Container network management
* Docker compose with `nerdctl compose up`

`nerdctl` are quite user friendly and provide identical to `docker` and `podman`

#### crictl

- Kubernetes using this tool to communicate to containerd

## 3. Integrate

- Containerd can be used in many places as it is designed to be embedded into larger systems.

2 frequent use-cases using containerd are docker and kubernetes. But others like faasd, crio also use.

Command of `crictl` is supposed to be similar like docker:

```
crictl ps

crictl rm <container-id>
```

- Containerd does not provide building option.
