# DevOps on AWS Real Project - All In One

## Infrastructure as Code - EKS - Terraform

### Terraform CLI

```sh
# Initialize Terraform — download providers and modules
terraform init

# Validate syntax and configuration (check for errors)
terraform validate

# (Optional) Format all .tf files recursively to follow Terraform HCL style
terraform fmt -recursive

# Preview infrastructure changes using variables from terraform.develop.tfvars
terraform plan -var-file="terraform.develop.tfvars"

# Apply (deploy) infrastructure automatically without confirmation
terraform apply -var-file="terraform.develop.tfvars" -auto-approve

# (Optional) Refresh only local Terraform state with real values from AWS
# terraform refresh -var-file="terraform.develop.tfvars"

# Destroy all resources created by this Terraform configuration
terraform destroy -var-file="terraform.develop.tfvars" -auto-approve

```

### EKS Connect CLI

```sh
# Connect EKS Cluster
aws eks update-kubeconfig --region  us-east-1 --name devops-hoangguruu-develop-eks-01

# Alis 
k=kubectl
kubectl get node
k get node
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

#### Setup Ingress Nginx Controller

- You can reference this way
[Setup Ingress Nginx Controller](https://kubernetes.github.io/ingress-nginx/deploy/)

```sh
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

helm uninstall ingress-nginx --namespace ingress-nginx


```
#### Installing cert-manager
- You can reference this way
[Installing cert-manager ](https://cert-manager.io/docs/installation/)

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Uninstall
helm uninstall cert-manager --namespace cert-manager

```

#### Create file cluster-issuer.yaml:
```sh
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: hoangguruu@gmail.com 
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

```sh
# The ClusterIssuer defines how cert-manager will request certificates
kubectl apply -f eks/cluster-issuer.yaml
kubectl get clusterissuer
```
#### Run Nginx Testing App
```sh
kubectl apply -f eks/app-test.yaml
kubectl get pod
kubectl get svc
kubectl get ingress
kubectl get certificate -A
kubectl describe certificate hoangguruu-id-vn-tls
```
##### Notice: 
Cloudflare: SSL/TLS encryption - Current encryption mode: Full




-------------------------------





