# DevSecOpsLab

## Setup
* `mise install`
* [Using ctlptl to setup Kind & Tilt with a registry](https://github.com/tilt-dev/ctlptl?tab=readme-ov-file#kind-with-a-built-in-registry-at-a-random-port)
    * `ctlptl create cluster kind --name kind-devsecops --registry=ctlptl-registry`
* `tilt up` 
* Jenkins will be available at [http://localhost:9001/](http://localhost:9001/) (or the port you configured in the `Tiltfile`).
The admin password is available in the logs:
```
printf $(kubectl get secret --namespace ci jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```
### Kind manual setup
* `kind create cluster --name devsecops`
  * `~/.kube/config` will be updated with the new cluster context under the name `kind-devsecops`.
  * You can switch to this context using `kubectl config use-context kind-devsecops`.

## Tear down
* `kind delete cluster --name devsecops`


## Jenkins
* [Helm chart readme](https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/README.md)
* [Helm template values](https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES.md)
* [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/)
* Available jenkins values configurable via helm `helm show values jenkins/jenkins`
* [Configuration as Code](http://localhost:9001/manage/configuration-as-code/reference) reference doc


## To Do
* ~~Add kind port in the cluster setup, or do this via tilt - done via tilt~~
* Add ingress controller
* Add ingress for Jenkins
* Add plugins for Jenkins via [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/)
  * [Blue Ocean](https://plugins.jenkins.io/blueocean/)
  * [Configuration as Code - Groovy Scripting Extension](https://plugins.jenkins.io/configuration-as-code-groovy/)