# DevOps on AWS Real Project - All In One

## Advanced Operation

### 

- 
[Install Docker on Ubuntu](https://www.google.com)

# The default Istio installation uses automatic sidecar injection. Label the namespace that will host the application with istio-injection=enabled:
kubectl label namespace default istio-injection=enabled


kubectl label namespace default istio-injection=disabled --overwrite
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
    - rancher.saurieng.site
    secretName: rancher-tls
  rules:
  - host: rancher.saurieng.site
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




3) Flow chuẩn từ đầu đến cuối
Bước A — Cài Vault

Nếu chạy trong cluster, cài Vault bằng Helm. HashiCorp khuyến nghị Helm chart cho Vault trên Kubernetes.

Ví dụ hướng làm:

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault -n vault --create-namespace

Nếu muốn dùng injector thì cần bật injector trong Helm values hoặc chart config. Vault Helm chart có phần cấu hình cho injector service/webhook.

Bước B — Enable Kubernetes auth trong Vault

Vault cần tin tưởng Kubernetes cluster để Pod auth bằng ServiceAccount token. Auth method chính thức là Kubernetes auth.

Ý tưởng:

vault auth enable kubernetes

Sau đó cấu hình:

Kubernetes API server

CA cert

token reviewer JWT

Đây là bước nối Vault với cluster. Vault docs gọi đây là cấu hình Kubernetes auth method.

Bước C — Ghi secret vào Vault

Ví dụ với KV v2:

vault kv put secret/bookinfo/ratings MONGO_DB_URL="mongodb://mongodb:27017/test"

Secret thật nằm trong Vault, không nằm trong Git/YAML.

Bước D — Tạo policy trong Vault

Policy quyết định Pod nào được đọc path nào.

Ví dụ:

path "secret/data/bookinfo/ratings" {
  capabilities = ["read"]
}

Rồi apply:

vault policy write ratings-policy ratings-policy.hcl

Vault docs nêu pod phải được bind tới một Vault role và policy phù hợp để đọc secret mong muốn.

Bước E — Tạo Vault role map với Kubernetes ServiceAccount

Ví dụ Pod ratings dùng serviceAccountName: bookinfo-ratings.

Bạn tạo role trong Vault để nói:

service account bookinfo-ratings

namespace default

được dùng policy ratings-policy

Ví dụ ý tưởng:

vault write auth/kubernetes/role/ratings \
  bound_service_account_names=bookinfo-ratings \
  bound_service_account_namespaces=default \
  policies=ratings-policy \
  ttl=24h

Đây là chỗ “Vault tin Pod nào trong cluster”. Cơ chế này là chính thức của Vault Injector/Kubernetes auth.

4) Để Pod nhận secret thế nào?
Cách A — Dùng Vault Agent Injector

Pod cần:

có service account riêng

có annotation để Vault inject

Ví dụ cho ratings:

metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "ratings"
    vault.hashicorp.com/agent-inject-secret-ratings-env: "secret/data/bookinfo/ratings"
    vault.hashicorp.com/agent-inject-template-ratings-env: |
      {{- with secret "secret/data/bookinfo/ratings" -}}
      export MONGO_DB_URL="{{ .Data.data.MONGO_DB_URL }}"
      {{- end }}

Các annotation này là cơ chế chính thức của Vault Agent Injector.

Sau đó container app sửa command để load file Vault render ra:

command: ["/bin/sh", "-c"]
args:
  - source /vault/secrets/ratings-env && node ratings.js 9080

HashiCorp có ví dụ chính thức kiểu “export secrets as env vars” và app source file đó khi startup.

Ý nghĩa

Secret thật ở Vault

Injector tự chèn agent

Agent render file /vault/secrets/ratings-env

App source file đó

process.env.MONGO_DB_URL sẽ có giá trị

Đây là cách đúng nếu app của bạn đang đọc process.env.MONGO_DB_URL.

Cách B — Dùng Vault Secrets Operator

Nếu bạn muốn cluster có Kubernetes Secret để app dùng kiểu cũ, cài VSO bằng Helm. HashiCorp nói Helm là cách recommend để cài VSO.

Sau đó bạn tạo CRD như VaultAuth, VaultStaticSecret để sync từ Vault sang K8s Secret. HashiCorp mô tả VSO sync secret từ Vault sang Kubernetes Secret “natively”.

Khi sync xong, Deployment dùng kiểu quen thuộc:

env:
  - name: MONGO_DB_URL
    valueFrom:
      secretKeyRef:
        name: ratings-secret
        key: MONGO_DB_URL
Ý nghĩa

Secret gốc vẫn ở Vault

VSO tạo/sync thành ratings-secret trong namespace

Pod đọc như secret Kubernetes bình thường

Cách này dễ nhất cho app hiện tại của bạn.