# Work with EKS

## Config

```sh
# Connect
aws eks update-kubeconfig --region  us-east-1 --name hr-stag-eksdemo1-guru

# Config Map | Secrets

# Role
```

## Neccesary Tools Setup
```sh
# Metric Servers
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

kubectl get deployment -n kube-system | grep metrics-server
kubectl top node

# Setup LENS IDE

# Setup AWS Loadbalancer Controller 
https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

# Setup Ingress Nginx Controller 
https://spacelift.io/blog/kubernetes-ingress

# SSL -
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Tạo file cluster-issuer.yaml:

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # 📌 Đổi email của bạn ở đây
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx

## Annotation
nginx.ingress.kubernetes.io/ssl-redirect: "true"  
cert-manager.io/cluster-issuer: letsencrypt-prod
## Add tls
tls:
  - hosts:
    - hoangguruu.id.vn
    secretName: hoangguruu-id-vn-tls
## Cloudflare Full SSL 
kubectl get certificate -A
kubectl describe certificate hoangguruu-id-vn-tls

# Rancher 

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.hoangguruu.id.vn \
  --set bootstrapPassword="admin"

kubectl get pods -n cattle-system

## rancher-ingress.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rancher-ingress
  namespace: cattle-system
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod  # Dùng Let's Encrypt để cấp SSL
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - rancher.hoangguruu.id.vn
    secretName: rancher-tls
  rules:
  - host: rancher.hoangguruu.id.vn
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rancher
            port:
              number: 80

## check certificate
kubectl get certificate -A

kubectl logs -n cattle-system deployment/rancher

### NC4y3xHhthZGF5T5


# Autoscaler 

✅ Bước 1: Cấu hình Terraform để hỗ trợ autoscaling
Bạn cần định nghĩa min/max node để Cluster Autoscaler có thể scale.

✅ Bước 2: Cài đặt Cluster Autoscaler trên Kubernetes
📌 Tạo IAM Policy cho Cluster Autoscaler

json
Copy
Edit
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
📌 Tạo policy trong AWS

bash
Copy
Edit
aws iam create-policy \
    --policy-name EKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler-policy.json
📌 Attach policy vào IAM role của node group

bash
Copy
Edit
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/EKSClusterAutoscalerPolicy \
    --role-name eks-node-group-role
📌 Deploy Cluster Autoscaler trên Kubernetes

bash
Copy
Edit
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/cluster-autoscaler-autodiscover.yaml
📌 Sửa Deployment Cluster Autoscaler

bash
Copy
Edit
kubectl edit deployment cluster-autoscaler -n kube-system
Tìm dòng:

yaml
Copy
Edit
command:
  - ./cluster-autoscaler
  - --cloud-provider=aws
  - --nodes=2:5:eks-node-group-name  # Chỉnh min:2, max:5
📌 Kiểm tra Cluster Autoscaler

bash
Copy
Edit
kubectl logs -f deployment/cluster-autoscaler -n kube-system


# ArgoCD - admin - 8EURCCN7Mz0UeGdn

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

helm install argocd argo/argo-cd \
  --namespace argocd \
  --set redis.persistence.enabled=false \
  --set controller.metrics.enabled=true \
  --set repoServer.persistence.enabled=false \
  --set server.extraArgs="{--insecure}" \
  --set server.ingress.enabled=false \
  --set configs.cm."application\.instanceLabelKey"="argocd.argoproj.io/instance"


## Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: argocd.hoangguruu.id.vn
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  name: https


# 
```

## Setup Tools Platform Ecosystem

```sh
# CI/CD : Jenkins

helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --create-namespace \
  --set controller.serviceType=ClusterIP \
  --set controller.ingress.enabled=false \
  --set controller.admin.username=admin \
  --set controller.admin.password=admin123

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=ClusterIP \
  --set controller.ingress.enabled=false \
  --set controller.admin.username=admin \
  --set controller.admin.password=admin123 \
  --set persistence.enabled=false  # Không dùng Persistent Volume

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set persistence.existingClaim="" \
  --set persistence.storageClass="" \
  --set persistence.volumes[0].name=jenkins-data \
  --set persistence.volumes[0].hostPath.path="/data/jenkins" \
  --set persistence.volumeMounts[0].mountPath="/var/jenkins_home" \
  --set persistence.volumeMounts[0].name=jenkins-data


## Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod  # Nếu bạn dùng SSL, nếu không có thì bỏ dòng này
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - jenkins.hoangguruu.id.vn  # ⚠️ Thay bằng domain của bạn
    secretName: jenkins-tls
  rules:
  - host: jenkins.hoangguruu.id.vn  # ⚠️ Thay bằng domain của bạn
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: jenkins
            port:
              number: 8080


kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d && echo

# Log : ELK

# Monitoring : Grafana - Prometheus ( Custom more ) Loki
prom-operator


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

## Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: grafana.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kube-prometheus-stack-grafana
            port:
              number: 80


# Splunk

```

## Any Tools

```sh
# Kafka

# Rabbit MQ

# Traefik ( similar nginx controller - so sanh)

# Vault

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  --set server.dataStorage.enabled=false \
  --set server.dev.enabled=true \
  --set ui.enabled=true


## Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vault-ingress
  namespace: vault
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - vault.yourdomain.com
      secretName: vault-tls
  rules:
    - host: vault.yourdomain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: vault-ui
                port:
                  number: 8200



## Unseal Key: x6ZXKNVYDbfYfBtvGqxBsVaJfqqQDst/UaVPc/AwpkA=
## Root Token: root

kubectl exec -it -n vault vault-0 -- /bin/sh

vault status
vault login <token>
vault kv put secret/myapp/config username=admin password=123456

vault kv put secret/myapp/config $(cat .env | xargs)


# Spacelit
```

## Solution

```sh
# Scale trigger HPA
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

# Scale trigger Cluster

# CI/CD 

kubectl create secret docker-registry ecr-secret \
  --docker-server=736059458620.dkr.ecr.ap-southeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region ap-southeast-1)" \
  --docker-email=hoangguruu@gmail.com \
  -n jenkins



# Security
```