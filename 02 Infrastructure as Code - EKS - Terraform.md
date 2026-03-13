# DevOps on AWS Real Project - All In One

## Infrastructure as Code - EKS - Terraform

### Terraform CLI

```sh
# Initialize Terraform 
terraform init

# Validate syntax and configuration 
terraform validate

# Preview infrastructure
terraform plan -var-file="terraform.develop.tfvars"

# Apply without confirmation
terraform apply -var-file="terraform.develop.tfvars" -auto-approve

# Destroy all resources created by this Terraform configuration
terraform destroy -var-file="terraform.develop.tfvars" -auto-approve

```

### EKS Connect CLI

```sh
# Connect EKS Cluster
aws eks update-kubeconfig --region  us-east-1 --name devops-on-aws-all-in-one-prod-eks-01

# Kubectl Command Line  

## Alias
k=kubectl

# 1 Check Basic Resource
kubectl get nodes
k get nodes
k get ns
k get pods
k get deployments
k get svc
k get ingress
k get pvc
k get pv
k get configmap
k get secret
k get sa
k get events

## 2 Check in namespace
k get pods -n my-namespace

## 3 Check ALL namespace
k get pods -A
k get all -A

## 4 Check detail
k describe node <node-name>

## 5 Check with output
k get nodes -o wide
k get pod <pod-name> -o yaml

## 6 Check realtime 
k get pods -w

## 7 Check logs
k logs <pod-name>
k logs <pod-name> -f
k logs <pod-name> -c <container-name>
k logs deployment/<deployment-name>
k logs deployment/<deployment-name> -f

## 8 Check shell in pod
k exec -it <pod-name> -- /bin/sh
k exec -it <pod-name> -- /bin/bash

## 9 Check resource usage
k top nodes
k top pods
k top pods -A

## 10 Check with label
k get pods -l app=nginx

## 11 Check rollout / status deploy
k rollout status deployment/<deployment-name>
k rollout history deployment/<deployment-name>
## 12 Check current context / cluster 
k config current-context
k config get-contexts
k cluster-info
k cluster-info dump

## 13 Resources short name
nodes        = no
namespaces   = ns
pods         = po
services     = svc
deployments  = deploy
ingress      = ing
configmaps   = cm

### Example
k get no
k get po -A
```

### Work with EKS - Neccesary Tools Setup
#### Metric Servers
- You can reference this way
[Setup Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

kubectl get deployment -n kube-system | grep metrics-server
kubectl top node
```

-------------------------------





