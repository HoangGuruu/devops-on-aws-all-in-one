# DevOps on AWS Real Project - All In One

## Advanced Operation

###  Vault

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

