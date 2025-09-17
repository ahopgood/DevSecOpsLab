# DevSecOpsLab

## Setup
* `mise install`
* [Using ctlptl to setup Kind & Tilt with a registry](https://github.com/tilt-dev/ctlptl?tab=readme-ov-file#kind-with-a-built-in-registry-at-a-random-port)
    * `ctlptl create cluster kind --name kind-devsecops --registry=ctlptl-registry`
* Set up your secrets as an environmental variables:
  * github token:
    * `export JENKINS_SECRET_CREDENTIALS_TOKEN=<your-secret-token>`
  * dockerhub token:
    * `export JENKINS_SECRET_CREDENTIALS_DOCKERHUB=<your-secret-token>`
  * NIST National Vulnerability Database (NVD) API Key:
    * `export JENKINS_SECRET_CREDENTIALS_NVD_API_KEY=<your_key>`
  * Depdendency Track API Key:
    * `export JENKINS_SECRET_CREDENTIALS_DEPENDENCY_TRACK_API_KEY=<your_key>`
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
* And delete the registry if you created one:
  * `ctlptl delete registry ctlptl-registry`
* or `ctlptl delete cluster kind-devsecops --cascade true` to delete both the cluster and registry


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
  * ~~[Blue Ocean](https://plugins.jenkins.io/blueocean/)~~
  * ~~[Configuration as Code - Groovy Scripting Extension](https://plugins.jenkins.io/configuration-as-code-groovy/)~~


## Dependency Track
* Requires an ingress controller like nginx-ingress to be installed.
* Add to `/etc/hosts`:
```
127.0.0.1 dependencytrack.example.org
```
* `tilt up`
* Then it should be available at [http://dependencytrack.example.org:9002](http://dependencytrack.example.org:9002)
* Username `admin` and password `admin`
* [Documentation](https://dependencytrack.org/docs/quick-start-guide/)
* [Documentation of the OpenAPI Spec](https://docs.dependencytrack.org/integrations/rest-api/)
  * **NOTE** this requires the backend service to be available which it isn't by default [http://dependencytrack.example.org:9002/api/openapi.yaml](http://dependencytrack.example.org:9002/api/openapi.yaml)
* Uses the [Evryfs Helm Chart](https://artifacthub.io/packages/helm/evryfs-oss/dependency-track)
### Setting up an API key
* `Administration` -> `Access Management` -> `Teams` -> `Automation` -> `API Keys`
* Add admin to automation team:
  * `Managed Users` -> `Admin` -> `Team membership` -> `+` -> `Automation`
  * 
### To do
* Add new admin password via the API/helm chart
* Add base url
* 


### Jenkins Dependency Track Plugin
* [Jenkins Plugin](https://plugins.jenkins.io/dependency-track/)
* Dependency track is required to be installed and running **before** Jenkins so we can configure the plugin via JCaSC with the API key obtained from dependency track
* The plugin requires Dependency Track version 4.12.0 or later
  * Testing the connection in Jenkins gives this warning:
  * > The detected version 4.6.3 is older than the required version 4.12.0 and is no longer supported
* JCaSC configuration for the Dependency Track plugin in Jenkins
```
unclassified:
  dependencyTrackPublisher:
    dependencyTrackUrl: http://dependency-track-apiserver.dependency-track.svc.cluster.local
    dependencyTrackAutoCreateProjects: true
```
#### Troubleshooting
* Jenkins successfully connects to Dependency Track and uploads the SBOM but the polling check for the processing fails:
* There is an open issue for something like this here: [https://github.com/DependencyTrack/dependency-track/issues/3434](https://github.com/DependencyTrack/dependency-track/issues/3434)
```
javax.ws.rs.NotFoundException: HTTP 404 Not Found
	at org.glassfish.jersey.server.ServerRuntime$1.run(ServerRuntime.java:252)
	at org.glassfish.jersey.internal.Errors$1.call(Errors.java:248)
	at org.glassfish.jersey.internal.Errors$1.call(Errors.java:244)
	at org.glassfish.jersey.internal.Errors.process(Errors.java:292)
	at org.glassfish.jersey.internal.Errors.process(Errors.java:274)
	at org.glassfish.jersey.internal.Errors.process(Errors.java:244)
```
* When trying to test the connection between the Jenkins plugin and Dependency Track you get this warning:
  * > The detected version 4.6.3 is older than the required version

#### To Do
* It would be nice to be able to add the `dependencyTrackApiKey:dependency-track-api-key` as a Jenkins secret automatically
* Example `additionalExistingSecret` to add to the helm install command:
```
- name: secret-credentials
  keyName: dependency-track-api-key
```
* Tilt secret setup example:
```
k8s_yaml(secret_from_dict("secret-credentials", namespace="ci", inputs = {
    ...    
    'dependency-track-api-key', os.getenv('JENKINS_SECRET_CREDENTIALS_DEPENDENCY_TRACK_API_KEY')
}))

```
* JCaSC configuration store the api key as a secret:
```
- string:
  description: Dependency Track API Key
  id: dependency-track-api-key
  scope: GLOBAL
  secret: ${dependency-track-api-key}
```


## ArgoCD
* Username `admin`
* Password `devSec0ps`
* You can get the initial password by running:
```
kubectl -n argocd get secret argocd-initial-admin-secret \
          -o jsonpath="{.data.password}" | base64 -d; echo
```