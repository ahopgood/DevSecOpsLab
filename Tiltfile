
load('ext://helm_resource', 'helm_resource', 'helm_repo')
helm_repo('jenkins-repo', 'https://charts.jenkins.io', labels=['jenkins'])

k8s_yaml('.infra/k8s/jenkins/namespace.yaml')
k8s_resource(new_name='jenkins-namespace', objects=['ci:namespace'], labels=['jenkins'])

load('ext://secret', 'secret_from_dict')
k8s_yaml(secret_from_dict("secret-credentials", namespace="ci", inputs = {
    'secret-credentials-token' : os.getenv('JENKINS_SECRET_CREDENTIALS_TOKEN'),
    'nvd-api-key' : os.getenv('JENKINS_SECRET_CREDENTIALS_NVD_API_KEY')
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

# Ingress Controller
# Updated timeout, needed for installing the nginx controller
update_settings ( max_parallel_updates = 3 , k8s_upsert_timeout_secs = 60 , suppress_unused_image_warnings = None )

load('ext://helm_resource', 'helm_resource', 'helm_repo')
helm_repo('ingress-nginx-repo', 'https://kubernetes.github.io/ingress-nginx')
helm_resource('ingress-nginx', 'ingress-nginx/ingress-nginx',
    resource_deps=['ingress-nginx-repo']
)
k8s_resource(workload='ingress-nginx', port_forwards='9002:80')

# Dependency Track
helm_repo('evryfs-oss', 'https://evryfs.github.io/helm-charts/', labels=['dependency-track'])

k8s_yaml('.infra/k8s/dependency-track/namespace.yaml')
k8s_resource(new_name='dependency-track-namespace', objects=['dependency-track:namespace'], labels=['dependency-track'])

helm_resource('dependency-track', 'evryfs-oss/dependency-track',
    resource_deps=['evryfs-oss', 'dependency-track-namespace'],
    namespace='dependency-track',
    labels=['dependency-track'],
    flags=[
      '--values=.infra/k8s/dependency-track/deptrack.values.yaml',
    ],
    deps=[
        '.infra/k8s/dependency-track/deptrack.values.yaml'
    ]
)