# Job

## 1. Definition

-   In k8s, Job is responsible for the numerous of pod running.
-   A Job is done when Pods are run in a specific number. Job will track completions of Pods
-   Deleting a Job will clean up the Pods it created
-   Suspending a Job will delete **active Pods** until the Job is resume

## 2. Common script

-   Get all pods in a Job:

```
kubectl get pods --selector=job-name=pi --output=jsonpath='{.items[*].metadata.name}'
```

## 3. Spec

-   A Job spec will include: `apiVersion`, `kind`, `metadata`, `spec`
-   In `spec`, the `spec.template` is required and is a **pod template**
-   Pod selector
-   `spec.template.spec.restartPolicy` must be `Never` or `OnFailure`
-   `.spec.selector` should be optional. Better define `spec.template.spec.selector`

### 3.1 Parallelism and Completions

This is a most important thing of a Job

-   If nothing is specified, then only 1 pod is started, unless the pod fails
-   Pod terminated successfully -> Job is complete

#### Parallel & Completions

-   If a number is specific in `spec.completions`, multiple Pods will be created and run
-   Job is Done when all Pods terminated successfully
-   `spec.completionMode="Indexed"` will return an index number of a completion order, otherwise, only completed is marked.
-   In a work queue, `spec.completions` will not be specific, only `spec.parallelism`. When _any_ pod terminated with success -> the Job is marked as completed, other Pods will exit
-   `spec.paralellism` means how many Pods of this Job can run in the same time.
