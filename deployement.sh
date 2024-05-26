#!/bin/bash

# Variables (update these as needed)
CLUSTER_NAME="example.k8s.local"
STATE_BUCKET="kops-state-bucket-example"
KOPS_STATE_STORE="s3://$STATE_BUCKET"
NODE_COUNT=2
NODE_SIZE="t2.medium"
MASTER_SIZE="t2.medium"
ZONE="us-west-2a"
NAMESPACE="lamp-namespace"

# Function to check if required commands are installed
check_prerequisites() {
  echo "Checking prerequisites..."
  for cmd in aws kops kubectl; do
    if ! command -v $cmd &> /dev/null; then
      echo "$cmd is required but not installed. Please install $cmd."
      exit 1
    fi
  done
  echo "All prerequisites are met."
}

# Function to create S3 bucket for kops state
create_s3_bucket() {
  echo "Creating S3 bucket for kops state storage..."
  aws s3api create-bucket --bucket $STATE_BUCKET --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
  aws s3api put-bucket-versioning --bucket $STATE_BUCKET --versioning-configuration Status=Enabled
  export KOPS_STATE_STORE=$KOPS_STATE_STORE
}

# Function to create Kubernetes cluster with kops
create_cluster() {
  echo "Creating Kubernetes cluster with kops..."
  kops create cluster --name=$CLUSTER_NAME --zones=$ZONE --node-count=$NODE_COUNT --node-size=$NODE_SIZE --master-size=$MASTER_SIZE --dns-zone=$(echo $CLUSTER_NAME | cut -d. -f2-)
  kops update cluster --name $CLUSTER_NAME --yes
  echo "Waiting for cluster to be ready..."
  kops validate cluster --wait 10m
}

# Function to create namespace
create_namespace() {
  local ns="$1"
  echo "Creating namespace '$ns'..."
  kubectl create namespace "$ns"
}

# Function to deploy MySQL database
deploy_mysql() {
  local ns="$1"
  echo "Deploying MySQL database in namespace '$ns'..."
  kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  namespace: $ns
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: $ns
spec:
  ports:
    - port: 3306
  selector:
    app: mysql
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: $ns
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:5.7
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpassword
        - name: MYSQL_DATABASE
          value: mydatabase
        - name: MYSQL_USER
          value: user
        - name: MYSQL_PASSWORD
          value: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
EOF
}

# Function to deploy PHP application using Apache
deploy_php_apache() {
  local ns="$1"
  echo "Deploying PHP application using Apache in namespace '$ns'..."
  kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: apache-config
  namespace: $ns
data:
  index.php: |
    <?php
    \$servername = "mysql";
    \$username = "user";
    \$password = "password";
    \$dbname = "mydatabase";

    // Create connection
    \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

    // Check connection
    if (\$conn->connect_error) {
        die("Connection failed: " . \$conn->connect_error);
    }
    echo "Connected successfully";
    ?>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
  namespace: $ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - image: php:7.4-apache
        name: php-apache
        ports:
        - containerPort: 80
        volumeMounts:
        - name: php-config
          mountPath: /var/www/html
  volumes:
  - name: php-config
    configMap:
      name: apache-config
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache-service
  namespace: $ns
spec:
  selector:
    app: php-apache
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOF
}

# Function to verify the deployments
verify_deployments() {
  local ns="$1"
  echo "Verifying the deployments in namespace '$ns'..."
  kubectl rollout status deployment/mysql --namespace="$ns"
  kubectl rollout status deployment/php-apache --namespace="$ns"
  kubectl get services --namespace="$ns"
}

# Function to delete the Kubernetes cluster
delete_cluster() {
  echo "Deleting Kubernetes cluster..."
  kops delete cluster --name=$CLUSTER_NAME --yes
}

# Main script execution
check_prerequisites
create_s3_bucket
create_cluster
create_namespace "$NAMESPACE"
deploy_mysql "$NAMESPACE"
deploy_php_apache "$NAMESPACE"
verify_deployments "$NAMESPACE"

# Uncomment the following line to clean up the cluster after verification
# delete_cluster

echo "Kubernetes automation with kops and LAMP stack deployment completed successfully."
