# terraform #

terraform has all infraestructure as code for the entire stack.

### How do I get set up? ###

* Install terraform [here](https://learn.hashicorp.com/terraform/getting-started/install.html)
* Install AWS CLI [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html)
* Configusre your AWS Profile [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
* Install kubectl [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/)



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

