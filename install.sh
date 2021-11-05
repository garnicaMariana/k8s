#!/bin/bash

# Set Variables
export AWS_REGION="us-east-2"
export EKS_CLUSTER="eks-cluster-uT9o"

# Upgrade OS
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y unzip tree

# EKS Toolset (includes kubectl, AWS-CLI and IAM Authenticator)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/bin

# Install Kubectl
# From AWS - specify version
# curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
# From K8S - always latest version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv kubectl /usr/bin

# Prepare Credentials
mkdir ~/.aws
touch ~/.aws/credentials
touch ~/.aws/config

cat credentials > ~/.aws/credentials
cat config > ~/.aws/config

aws sts get-caller-identity
# Two options to check: region and cluster name
aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER
kubectl describe configmap -n kube-system aws-auth

# Configure the auto completion for kubectl
source <(kubectl completion bash)

# Install kubectx and kubens to help with namespaces, contexts and clusters
sudo curl -sSL https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx_v0.9.4_linux_x86_64.tar.gz | sudo tar -C /usr/bin/ -xz
sudo curl -sSL https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens_v0.9.4_linux_x86_64.tar.gz | sudo tar -C /usr/bin/ -xz

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh

# Cert-Manager
curl -L -o kubectl-cert-manager.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/kubectl-cert_manager-linux-amd64.tar.gz
tar xzf kubectl-cert-manager.tar.gz
sudo mv kubectl-cert_manager /usr/local/bin

# Clean temporary files
rm -rf creds.txt EKS_Certificate awscliv2.zip config credentials kubectl-cert-manager.tar.gz LICENSES README.md get_helm.sh
