# Persistent Volumes & Persistent Volume Claims

## 1. Definition

-   PV: a piece of storage in the , provisioned by Storage Class
-   `PV` are volume plugins like `Volume`, have a lifecycle independent from Pods
-   PVC: A request of storage by a user, ~ Pod.
-   PVC can request specific size and accessMode

## 2. Lifecycle of volume and claim

There aare 2 ways: static + dynamic

### 2.1 Static

-   Carry the real detail of data storage.

### 2.2 Dynamic

When non static PV match PVC, cluster try to dynamically provision a volume for PVC

-   PVC request a storage class
-   admin created and configured that class for dynamic provisioning
-   claim request the class `""` will disable dynamic provisioning
-   cluster administrator needs to enable the DefaultStorageClass admission controller on the API server

## 3. Spec

### 3.1 Reserve a PV

-   Control plane can bind PVC to matching PV
-   If PV exists and has not reserved PVC through `claimRef` -> match

Spec example

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: foo-pvc
  namespace: foo
spec:
  storageClassName: "" # Empty string must be explicitly set otherwise default StorageClass will be set
  volumeName: foo-pv
  ...
```

Specify a PV so that no other PVC can claim:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: foo-pv
spec:
  storageClassName: ""
  claimRef:
    name: foo-pvc
    namespace: foo
  ...
```

### 3.2 Persistant Volume Type

These are currently support Volume type:

```
awsElasticBlockStore - AWS Elastic Block Store (EBS)
azureDisk - Azure Disk
azureFile - Azure File
cephfs - CephFS volume
csi - Container Storage Interface (CSI)
fc - Fibre Channel (FC) storage
gcePersistentDisk - GCE Persistent Disk
glusterfs - Glusterfs volume
hostPath - HostPath volume (for single node testing only; WILL NOT WORK in a multi-node cluster; consider using local volume instead)
iscsi - iSCSI (SCSI over IP) storage
local - local storage devices mounted on nodes.
nfs - Network File System (NFS) storage
portworxVolume - Portworx volume
rbd - Rados Block Device (RBD) volume
vsphereVolume - vSphere VMDK volume
```

Deprecated support type:

```
cinder - Cinder (OpenStack block storage) (deprecated in v1.18)
flexVolume - FlexVolume (deprecated in v1.23)
flocker - Flocker storage (deprecated in v1.22)
quobyte - Quobyte volume (deprecated in v1.22)
storageos - StorageOS volume (deprecated in v1.22)

photonPersistentDisk - Photon controller persistent disk. (not available after v1.15)
scaleIO - ScaleIO volume (not available after v1.21)

```

### 3.3 Spec detail

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /tmp
    server: 172.17.0.2
```

-   `capacity.storage`: Amount of capacity will be used for PV
-   `volumeMode` : `Block` or `Filesystem`
-   `accessModes`: Can be `ReadWriteOnce` (access by 1 node), `ReadOnlyMany` (access by n node), `ReadWriteMany` (access by n node), `ReadWriteOncePod` (access by 1 pod)

-   `persistentVolumeReclaimPolicy`: `Ratain` (manual reclaimation), `Recycle` (scrub `rm -rf /volume/*`), `Delete` (delete in associated storage)
-   `storageClassName`: See StorageClass for more detail

### 3.4 Delete a PVC

Sometimes, for misconfiguring, you will need to delete a misconfig PVC. To do that, please edit the PV which it is attached to
-> Remove

```
finalizers:
  - kubernetes.io/pv-protection

```
