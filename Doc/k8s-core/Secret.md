# Secret

## 1. Definition

-   An object contains small amount of sensitive data, such as password, token, a key
-   Can be put in a Pod spec, container image
-   Can be created independently from Pods
-   Similar to ConfigMap, but focus on confidential data

-   Recommend: Enable encryption at Rest for Secret
-   Recommend: Enable configure RBAC rules

## 2. Working with secret

### 2.1 kubectl

-   To create a secret, you will need to create a file contain the secret value:

```
echo -n 'admin' > ./username.txt
echo -n '12345678' > ./password.txt
```

`-n` for no newline character, avoid some unexpected result.

-   Then use kubectl to create from file

```
kubectl create secret generic db-user-pass \
  --from-file=./username.txt \
  --from-file=./password.txt
```

-   Default key name is the file name, but you can change it like:

```
kubectl create secret generic db-user-pass \
  --from-file=user=./username.txt \
  --from-file=pass=./password.txt
```

-   Or create from a value:

```
kubectl create secret generic db-user-pass \
  --from-literal=user=admin \
  --from-literal=pass=12345678
```

-   Get back the value by:

```
kubectl get secret db-user-pass -o jsonpath='{.data.user}' | base64 --decode
kubectl get secret db-user-pass -o jsonpath='{.data.pass}' | base64 --decode
```

## 3. Using secret

### 3.1 Use as file from a Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo               # Map to a volume -> mount to container
    secret:
      secretName:
      optional: false       # default setting; "mysecret" must exist
```

You can specific a path to mount only a subset of secret

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo               # Map to a volume -> mount to container
    secret:
      secretName: mysecret
      items:
      - key: user
        path: /path/to/subset/user
      defaultMode: 0400
```

All keys listed in Secret must exist or volume will not be created
`defaultMode`: for specify permission
