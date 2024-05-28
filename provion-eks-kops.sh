#!/bin/bash

CLUSTER_NAME="your-cluster-name"
AWS_REGION="your-aws-region"
S3_BUCKET="your-s3-bucket-for-kops-state"

kops create cluster --name=$CLUSTER_NAME --state=s3://$S3_BUCKET --zones=$AWS_REGION --yes

echo "Waiting for cluster to be ready..."
sleep 60 
kops validate cluster --name $CLUSTER_NAME --state s3://$S3_BUCKET

kops export kubecfg --name $CLUSTER_NAME --state s3://$S3_BUCKET

echo "EKS Cluster Deployed Successfully!"
kubectl cluster-info
kubectl get nodes
