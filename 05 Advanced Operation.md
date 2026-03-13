# DevOps on AWS Real Project - All In One

## Advanced Operation

### 

- 
[Install Docker on Ubuntu](https://www.google.com)


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