# DevOps on AWS Real Project - All In One

## Advanced Operation

### 

- 
[Install Docker on Ubuntu](https://www.google.com)

# The default Istio installation uses automatic sidecar injection. Label the namespace that will host the application with istio-injection=enabled:
kubectl label namespace default istio-injection=enabled

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

