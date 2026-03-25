# DevOps on AWS Real Project - All In One

## Advanced Operation

###  Setup Vault
[Setup Vault](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide)

```sh
# Add repo
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Create namespace
kubectl create namespace vault

helm install vault hashicorp/vault \
  -n vault \
  --set "server.standalone.enabled=true" \
  --set "ui.enabled=true" \
  --set "server.dataStorage.enabled=true" \
  --set "server.dataStorage.storageClass=gp2"

kubectl get pods -n vault

kubectl exec -n vault vault-0 -- vault status
```

```sh
# Initialize
kubectl exec -n vault vault-0 -- vault operator init

kubectl exec -n vault vault-0 -- vault operator unseal
kubectl exec -n vault vault-0 -- vault operator unseal
kubectl exec -n vault vault-0 -- vault operator unseal

kubectl exec -it -n vault vault-0 -- sh
export VAULT_TOKEN="ROOT_TOKEN_CUA_BAN"
vault login $VAULT_TOKEN

kubectl port-forward --address 0.0.0.0 -n vault svc/vault-ui 8200:8200
```
- Apply Domain
```sh
kubectl apply -f bookinfo/gateway-domain/vault-httproute.yaml
kubectl describe httproute vault-route -n vault

### Add RECORDS ON Cloudflare

kubectl apply -f bookinfo/gateway-domain/vault-certificate.yaml
kubectl get certificate -n default

```
###  Setup ArgoCD

[Setup ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/)

```sh
kubectl apply -n istio-system --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


kubectl apply -f bookinfo/gateway-domain/argocd-httproute.yaml
kubectl describe httproute argocd-route -n istio-system

### Add RECORDS ON Cloudflare

kubectl apply -f bookinfo/gateway-domain/argocd-certificate.yaml
kubectl get certificate -n default
```