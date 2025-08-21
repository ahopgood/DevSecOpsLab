# DevSecOpsLab

## Setup
* `mise install`
* [Using ctlptl to setup Kind & Tilt with a registry](https://github.com/tilt-dev/ctlptl?tab=readme-ov-file#kind-with-a-built-in-registry-at-a-random-port)
    * `ctlptl create cluster kind --name kind-devsecops --registry=ctlptl-registry`
* Set up your secrets as an environmental variables:
  * github token :
    * `export=JENKINS_SECRET_CREDENTIALS_TOKEN=<your-secret-token>`
  * dockerhub token:
    * `export JENKINS_SECRET_CREDENTIALS_DOCKERHUB=<your-secret-token>`
  * NIST National Vulnerability Database (NVD) API Key:
    * `export JENKINS_SECRET_CREDENTIALS_NVD_API_KEY=<your_key>`
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
  * Available jenkins values configurable via helm `helm show values jenkins/jenkins`
* [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/)
* [Configuration as Code](http://localhost:9001/manage/configuration-as-code/reference) reference doc

### Seed Jobs
* A seed job can be added to the `jobs.yaml` file
* It will use the [Jobs DSL](https://plugins.jenkins.io/job-dsl/) syntax
  * If you want o add a new job in its own file then you'll need to:
    * pass it into the helm command as a new `--value=<filename>.yaml` flag
    * also make sure it has the full helm *and* JCasC elements:
    ```
    controller:
    JCasC:
      configScripts:
        jenkins-casc-dsl-jobs: |
          jobs:
            - script: |
                multibranchPipelineJob('dso-demo') {
                 ....
    ```
  

## To Do
* ~~Add kind port in the cluster setup, or do this via tilt - done via tilt~~
* Add ingress controller
* Add ingress for Jenkins
* Add plugins for Jenkins via [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/)
  * [Blue Ocean](https://plugins.jenkins.io/blueocean/)
  * [Configuration as Code - Groovy Scripting Extension](https://plugins.jenkins.io/configuration-as-code-groovy/)