# Basic

When kubernetes cluster started to use several components as a template
(For example, a project always contains several container, several setup like StatefulSet, Job, Secret, ...), that's when Helm kicks in.

Helm helps building components (in a cluster) faster. In a common sense, Helm is similar to IaC, but more focuses on the components and the ability to manage and modify the cluster, where as IaC focuses on Infrastructure and managin resource.

## 1. How Helm works ?

-   Helm using a specific configuration file, which named Charts.
-   Charts includes: `Chart.yaml`, `values.yaml`, `charts/` (sub-charts folder), `templates/` (template folder)
-   Helm will use info defined in `Chart.yaml` and `values.yaml` to render templates into a files (k8s config files)
-   Helm uses information defined and gives to Tiller to manage k8s cluster.

## 2. Components

-   **Charts**: k8s template file combined into a single file, also contain **Values** to be customized
-   **Release**: A version of **Chart** which is currently running
-   **Values**: Specific values defined in `values.yaml` and apply to current **Release**.

## 3. Command

-   Install a release from a chart:

```
helm -n <namespace> install <release-name> <chart> --set replicaCount=2 --set image.debug=true
```

Install with some specific valules set.

All values which can be set will be list by:

```
helm show values bitnami/apache

# This for showing color
helm show values bitnami/apache | yq e
```

-   Uninstall a release

```
helm -n <namespace> uninstall <release-name>
```

-   List repo and update repo

```
helm repo list
helm repo update
helm search repo <keyword>
```
