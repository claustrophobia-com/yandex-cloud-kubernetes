# Kubernetes Infrastructure in Yandex Cloud


### All-in-one production-ready solution

This project originally started as claustrophobia.com project infrastructure.

Decided to open sources for education and production usage.


## Contents

The project was built as terraform modular structured mono repository,
containing submodules to deploy high-available infrastructure services
using Yandex Cloud Managed Kubernetes and other platform services.


### Project structure

The modules are mostly split by semantics, but some provides exact resource.

```
├── docs
├── common
│   ├── basic-auth
│   │   └── scripts
│   └── external-name-service
└── modules
│   ├── vpc
│   ├── iam
│   ├── cluster
│   │   └── modules
│   │       └── node_groups
│   ├── admins
│   ├── nfs-server-provisioner
│   ├── prometheus
│   ├── elasticsearch
│   │   └── modules
│   │       ├── cluster
│   │       ├── filebeat
│   │       ├── kibana
│   │       ├── logstash
│   │       └── operator
│   │           └── sources
│   ├── nginx-ingress
│   ├── cert-manager
│   │   └── modules
│   │       ├── crds
│   │       └── issuers
│   ├── kubernetes-dashboard
│   ├── registry
│   └── secrets
├── get-kubectl-provider.sh
├── get-yc-cli.sh
├── files.tf
├── output.tf
├── variables.tf
└── main.tf
```

#### Main module

- Based on main.tf file of project root.

- Input variables are defined in variables.tf file of project root.

- Output variables are defined in output.tf

- File outputs are defined in files.tf

- Contain modules for common (abstract) and target usage

- Defines and modifies input structures to configure project modules

- Provide entrypoint for module configurations

- Configure providers depends on kubernetes api to use yc-cli to get token

Input and output variables of the module are described in [docs/variables.md](docs/variables.md)


### Modules description


#### vpc

Module to deploy virtual private cloud for infra to deploy on.

- Creates network and subnets for given list of zone names.


#### iam

Module to deploy IAM resources for cluster to use.

- Creates service accounts for cluster and for nodes and assign folder roles.


#### cluster

Module to deploy Kubernetes cluster and defined node groups.

- Creates Managed Kubernetes Cluster configured to use regional master by given `location_subnets` value.

- Creates Cluster Node Groups by given `cluster_node_groups` value, dynamically allocated by given `location_subnets`


#### admins

Module to deploy kubernetes service accounts for each admin
and prepare their ssh-keys for cluster nodes deploying.

- Creates service accounts for given `admins` value and bind `cluster-admin` role to them.

- Prepares `kubeconfigs` including prefetched secret token for output.

- Prepares `ssh-keys` string for cloud-init of cluster nodes.


#### registry

Module to deploy Container Registry for given name.


#### nginx-ingress

Module to deploy nginx-ingress controller helm chart configured as DaemonSet.

- Creates helm release in `nginx-ingress` to deploy nginx-ingress service pods, configured with DaemonSet for given `node_selector`

- Creates `ingress` with type `LoadBalancer` to expose nginx-ingress service

- Provides ingress class `nginx` used by many other modules

- Outputs `load_balancer_ip` for deployed ingress service.


#### cert-manager

Module to deploy cert-manager helm chart and cluster issuers
(staging and production) to to automate certificates issuing by Let's Encrypt

- Downloads and applies CRDs for cert-manager.

- Creates helm release to deploy cert-manager service pods.

- Applies Applies cluster issuers for given staging and production emails.

- Provides cluster issuers, used by many other modules as ingress configuration.


#### kubernetes-dashboard

Module to deploy kubernetes-dashboard helm chart exposed with nginx-ingress
and secured with Let's Encrypt certificate, automatically issued by cert-manager.

Could be useful to debug both required modules.

- Prepares `ingress` value for nginx-ingress helm chart based on given `ingress` value.

- Creates helm release in `kube-system` namespace to deploy kubernetes-dashboard service pod, configured with Deployment for given `node_selector`


#### nfs-server-provisioner

Module to deploy nfs-server-provisioner controller helm chart.

- Creates helm release in `nfs-server-provisioner` namespace to deploy nfs-server-provisioner service pod for given `node_selector`, configured to use PV on given `storage_class`.

- Creates `network-ssd` attached to node for given `storage_class`

- Provides `nfs-client` storage class used by many other modules


#### elasticsearch

Module to deploy ELK stack services to provide logging

- creates resources for given `namespace`

- operator submodule to deploy elasticsearch-operator

- cluster submodule to deploy high-available elasticsearch cluster for given `cluster_name`, `scale` and `node_selector`, configured to use PVs for given `storage_size` and `storage_class`

- kibana submodule to deploy kibana service pods and web-service, exposed by given `kibana_ingress`

- logstash submodule to deploy logstash helm chart

- filebeat submodule to deploy filebeat helm chart

- Provices streaming to elasticsearch for instance logs

- Provides exposed kibana service to watch the logs

- Provides elasticsearch and logstash host names for output

- Provides generated password of elastic user for output


#### prometheus

Module to deploy Prometheus-Alertmanager-Grafana stack services to provide monitoring

- creates resources for given `namespace`

- downloads and applies CRDs

- Creates helm release for given namespace to deploy prometheus-operator helm chart services, configured by given `configs`.



#### secrets

Common module to create opaque kubernetes secrets for each `opaque_secrets` for given `namespace`


#### basic-auth

Common module to create kubernetes opaque secret for basic-auth on given `username` and `password` using external bash script execution


#### external-name-service

Common module to create ExternalName kubernetes service for given `name` and `external_name` for given `namespace`


### Scripts


#### get-kubectl-provider.sh

Silently installs suitable release of gavinbunney/terraform-provider-kubectl to `terraform.d/plugins` of project root


#### get-yc-cli.sh

Silently installs suitable release of yc-cli to `yc-cli` directory in project root


### Execution

The order of execution is necessary at this point.


1. `git clone` this project

2. `./get-kubectl-provider.sh && ./get-yc-cli.sh`

3. configure all required variables of the main module as described in [docs/variables.md](docs/variables.md)

   `mv terraform.tfvars.example terraform.tfvars` and fill required values

4. `terraform plan -target module.cluster` and check your plan

5. `terraform apply -target module.cluster` and wait until k8s cluster will become HEALTHY

6. Configure yc-cli and get-credentials for newly created cluster

    [See Doc](https://cloud.yandex.ru/docs/managed-kubernetes/quickstart#add-conf)

7. `terraform apply -target module.nfs-server-provisioner`

8. `terraform apply -target module.nginx-ingress`

9. Create wildcard A DNS record for outputted `load_balancer_ip`

   `*.cluster_domain A IN load_balancer_ip`

10. `terraform apply -target module.cert-manager`

    check that all issuers are ready by `kubectl get clusterissuers`

11. `terraform apply -target module.admins -target local_file.kubeconfigs`

    check that output/kubeconfigs directory was created and contains files named as `admins`

12. `terraform apply -target module.kubernetes-dashboard`

    check that ingress is ready by `kubectl -n kube-system get ing -l app=kubernetes-dashboardkubectl -n kube-system get ing -l app=kubernetes-dashboard`

    try to access dashboard using web-browser with generated kubeconfig

13. `git clone https://github.com/Strangerxxx/yc-k8s-recept.git && cd yc-k8s-recept/sysctl-tuner && ./deploy.sh`

    and check that all sysctl-tuner's pods are running normally by `kubectl -n kube-system get po -l module=sysctl-tuner`

14. `terraform apply -target module.elasticsearch`

    and check that elasticsearch cluster HEALTH become green by `kubectl -n elasticsearch get elasticsearch`

    try to access kibana using web-browser with outputted `elasticsearch_user` value

15. `terraform apply -target module.prometheus`

    and check that all prometheus pods are running normally by `kubectl -n prometheus get pod`

    try to access Grafana using web-browser with user *admin* outputted `grafana_admin_password`


## TODO

- [ ] refactor

- [ ] deploy sysctl-tuner using helm and terraform

- [ ] refactor to separate modules configuration
