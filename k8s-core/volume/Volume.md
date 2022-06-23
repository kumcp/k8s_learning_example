# Volumes

## 1. Definition

There are many types of volumes can be managed in k8s

-   **Ephemeral volumes**: Have a lifetime of a pod
-   **Persistent volumes**: Can exist beyond the lifetime o a pod
-   All volume types will be persisted when container **restart**
-   Volume is a directory, accessible to container in a pod.
-   Container will see filesystem contents of container image, plus volumes mounted to it

## 2. Spec

-   To use a volume, add `.spec.volumes` in a Pod spec
-   Where to mount into container is defined in `.spec.containers[*].volumeMounts`

-   CSI Migration
-   cephfs
-   configMap
-   downwardAPI
-   emptyDir
-   fc (fibre channel)
-   hostPath
-   Creating a GCE persistent disk
-   GCE persistent disk
-   iscsi
-   local

### 2.2 ConfigMap

-   ConfigMap can be used to inject data into pods

### 2.3 emptyDir

-   First volume created in a pod, all containers inside this pod can access
-   When a pod is removed from a Node, this will be deleted permanently
-   Container crash will not remove emptyDir to be safe
-   `emptyDir.medium` can be disk, SSD, network storage. If it is set as `"Memory"`, k8s mounts tmpfs (Ram-backed memory)
-   Example

```
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```

### 2.4 Local

-   Represent a mounted local storage devices like disk, partition or dir.
-   Must set `PersistentVolume` nodeAffinity when using `local`
-   PersistentVolume can set `volumeMode` as `"Block"` or `"FileSystem"`

### 2.5 persistentVolumeClaim

-   PVC is for mounting volume into a pod
