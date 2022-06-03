# Pod

## 1. Definition

## 2. Command

-   Create a temporary pod (useful for test something inside):

```
kubectl run tmp --restart=Never --rm --image=<whatever-image> -i -- <command-to-test>
```

-   `--rm`: to remove pod after test
