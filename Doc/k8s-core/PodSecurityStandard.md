

There are 3 policies for Pod Security Standard:

1. Privileged
- Unrestricted policy, privilege escalation

2. Baseline
- Minimally restrictive policy, prevent privilege escalation
- Allow minimally specified Pod config

3. Restricted
- Heavily restricted policy, following current Pod hardening best practices.

We can usse this pod security by label of a namespace:

```

apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: prj1
    pod-security.kubernetes.io/enforce: baseline
  name: prj1
```
