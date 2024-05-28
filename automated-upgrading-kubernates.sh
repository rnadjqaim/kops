#!/bin/bash


CLUSTER_NAME="your-cluster-name"

NEW_K8S_VERSION=$(kops get latest kubernetes --output json | jq -r '.latestVersions[].version')

kops backup create --name $CLUSTER_NAME --yes

kops upgrade cluster --name $CLUSTER_NAME --yes

kops update cluster --name $CLUSTER_NAME --yes

kops rolling-update cluster --name $CLUSTER_NAME --yes


kubectl version

