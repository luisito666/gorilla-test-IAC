# HQIF terraform #

HQIF terraform has all infraestructure as code for the entire stack.

### How do I get set up? ###

* Install terraform [here](https://learn.hashicorp.com/terraform/getting-started/install.html)
* Install AWS CLI [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html)
* Configusre your AWS Profile [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
* Install kubectl [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

The roots folder has the different terraform parts for deploying different pieces of the infrastructure. 

1. roots/backend: The backend root contains all configuration files for deploy EKS cluster in AWS. The application module within has database and redis also include admin, api, marketdata and nodefix.
2. roots/frontend: this module deploys the frontend application with cloudfront.
3. roots/model_scripts: this deploys all c++ models in kubernetes under the model-scripts namespace.

### First deployment?

You need to configure a few resources in AWS and update terraform.tfvars to run.

1. Create an S3 bucket for the frontend and update var `code_store_bucket` with the bucket name.
2. Make sure all required containers are in the ECR registry and that you have access to it.
3. Create a VPC and update var `vpc_id` with the id.

### Review the changes to apply.

Navigate to root of the module 

```bash
cd roots/backend
terraform plan
```

### Apply the changes

```bash
terraform apply
```

### How to destroy the changes

NOTE: this destroys everything including data.

```bash
terraform destroy
```

## Kubernetes deployment.

All deployment of this project are made with the terraform kubernetes module instead of manually.

To use the kubectl command line tool you need to configure it to point at the cluster.

```bash
aws eks --region us-east-1 update-kubeconfig --name main_cluster
```

### How to view all deployments

```bash
kubectl get deployment --all-namespaces
```

By namespace

```bash
kubectl get deployment -n namespace
```

#### Namespaces

Main:

* default: api, redis, marketdata scripts and tt-fix stream
* model-scripts: all other model scripts
* timescale: database

Utils:

* grafana: visualisation dashboard
* kubernetes-dashboard: Kube management dashboard
* prometheus: metrics collection system

### How to view all pods

```bash
kubectl get pods --all-namespaces
```

You can use this to see pods that might not be running or that have been crashing and restarting.

by namespace

```bash
kubectl get pods -n namespace
```

### How to restart a deployment

After making changes to the code and generating the new docker image you can use the following comand to update the container.

```bash
kubectl rollout restart deploy name_of_deployment
```

