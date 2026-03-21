# DevOps on AWS Real Project - All In One

## Advanced Operation

###  
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

