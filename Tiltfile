
load('ext://helm_resource', 'helm_resource', 'helm_repo')
helm_repo('jenkins-repo', 'https://charts.jenkins.io', labels=['jenkins'])

k8s_yaml('.infra/k8s/jenkins/namespace.yaml')
k8s_resource(new_name='jenkins-namespace', objects=['ci:namespace'], labels=['jenkins'])

load('ext://secret', 'secret_from_dict')
k8s_yaml(secret_from_dict("secret-credentials", namespace="ci", inputs = {
    'secret-credentials-token' : os.getenv('JENKINS_SECRET_CREDENTIALS_TOKEN'),
    'nvd-api-key' : os.getenv('JENKINS_SECRET_CREDENTIALS_NVD_API_KEY'),
    'dependency-track-api-key' : os.getenv('JENKINS_SECRET_CREDENTIALS_DEPENDENCY_TRACK_API_KEY')
}))

load('ext://secret', 'secret_yaml_registry')
k8s_yaml(secret_yaml_registry("secret-credentials-dockerhub", namespace="ci", flags_dict = {
    'docker-server': 'https://index.docker.io/v1/',
    'docker-username': 'altairbob',
    'docker-password': os.getenv('JENKINS_SECRET_CREDENTIALS_DOCKERHUB'),
    'docker-email': 'altairbob@gmail.com',
}))

k8s_resource(new_name='secret-credentials', objects=[
    'secret-credentials:secret',
    'secret-credentials-dockerhub:secret'
    ], labels=['jenkins'], resource_deps=['jenkins-namespace']
)

helm_resource('jenkins', 'jenkins/jenkins',
    resource_deps=['jenkins-repo', 'jenkins-namespace', 'secret-credentials'],
    namespace='ci',
    labels=['jenkins'],
    flags=[
        '--version=5.8.60',
        '--values=.infra/k8s/jenkins/jenkins.values.yaml',
        '--values=.infra/k8s/jenkins/jobs.yaml'
        ],
    deps=[
        '.infra/k8s/jenkins/jenkins.values.yaml',
        '.infra/k8s/jenkins/jobs.yaml'
    ]
)

k8s_resource(workload='jenkins', port_forwards='9001:8080')

load_dynamic('.infra/k8s/nginx/Tiltfile')

k8s_yaml('.infra/k8s/argocd/namespace.yaml')
k8s_resource(new_name='argocd-namespace', objects=['argocd:namespace'], labels=['argocd'])

# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
load('ext://namespace', 'namespace_inject')
k8s_yaml(namespace_inject(read_file('.infra/k8s/argocd/argocd.yaml'), 'argocd'))
k8s_resource('argocd-applicationset-controller', labels=['argocd'], resource_deps=['argocd-namespace'])
k8s_resource('argocd-dex-server', labels=['argocd'], resource_deps=['argocd-namespace'])
k8s_resource('argocd-notifications-controller', labels=['argocd'], resource_deps=['argocd-namespace'])
k8s_resource('argocd-redis', labels=['argocd'], resource_deps=['argocd-namespace'])
k8s_resource('argocd-repo-server', labels=['argocd'], resource_deps=['argocd-namespace'])
k8s_resource('argocd-application-controller', labels=['argocd'], resource_deps=['argocd-namespace'])

k8s_resource('argocd-server', labels=['argocd'], resource_deps=['argocd-namespace'], port_forwards=['9003:8080', '9004:8083'])

local_resource('reset-password', '.infra/k8s/argocd/reset-password.sh', resource_deps=['argocd-server'])
