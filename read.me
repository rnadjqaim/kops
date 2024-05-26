# Kubernetes Cluster Automation with Kops and LAMP Stack Deployment

This repository contains a bash script that automates the process of creating a Kubernetes cluster using `kops` and deploying a LAMP (Linux, Apache, MySQL, PHP) stack application.

## Prerequisites

Before running the script, make sure you have the following tools installed and configured:

- [AWS CLI](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kops](https://github.com/kubernetes/kops)

Additionally, ensure you have:

- An AWS account with appropriate permissions.
- A domain managed in Route 53 or a subdomain.

## Script Overview

The script performs the following steps:

1. Checks for prerequisites.
2. Creates an S3 bucket for kops state storage.
3. Creates a Kubernetes cluster with `kops`.
4. Creates a namespace.
5. Deploys a MySQL database.
6. Deploys a PHP application using Apache.
7. Exposes the PHP application.
8. Verifies the deployments.
9. Optionally, cleans up resources.

## Usage

1. Clone the repository or save the script to a file, e.g., `kops_deploy_lamp.sh`.

2. Make the script executable:

    ```sh
    chmod +x kops_deploy_lamp.sh
    ```

3. Update the script variables at the top of the script with your own values, such as `CLUSTER_NAME`, `STATE_BUCKET`, `ZONE`, etc.

4. Run the script:

    ```sh
    ./kops_deploy_lamp.sh
    ```

5. To clean up the cluster after verification, uncomment the `delete_cluster` function call at the end of the script.

## Script Variables

- `CLUSTER_NAME`: The name of the Kubernetes cluster.
- `STATE_BUCKET`: The name of the S3 bucket for storing kops state files.
- `KOPS_STATE_STORE`: The S3 bucket URL for kops state storage.
- `NODE_COUNT`: The number of nodes in the cluster.
- `NODE_SIZE`: The instance type for the nodes.
- `MASTER_SIZE`: The instance type for the master node.
- `ZONE`: The AWS availability zone.
- `NAMESPACE`: The namespace for deploying the applications.

## Verification

After running the script, the MySQL database and the PHP application will be deployed, and the PHP application will be exposed via a LoadBalancer. You can verify the deployment by checking the status of the pods and services:

```sh
kubectl get pods -n <namespace>
kubectl get services -n <namespace>
