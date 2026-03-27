# DevOps on AWS Real Project - All In One

## Advanced Operation

###  Setup Vault
[Setup Vault](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide)

```sh
# Add repo
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install vault hashicorp/vault \
  -n istio-system \
  --create-namespace \
  --set "server.dev.enabled=true" \
  --set "server.dev.devRootToken=root" \
  --set "ui.enabled=true" \
  --set "injector.enabled=false"


# helm upgrade vault hashicorp/vault \
#   -n istio-system \
#   --create-namespace \
#   --set "server.dev.enabled=true" \
#   --set "server.dev.devRootToken=root" \
#   --set "ui.enabled=true" \
#   --set "injector.enabled=false" \
#   --set "server.extraEnvironmentVars.VAULT_ADDR=vault.hoangguruu.site" 

kubectl get pods -n istio-system

kubectl exec -n istio-system vault-0 -- vault status

kubectl logs -n istio-system vault-0
# Root Token: root

kubectl port-forward --address 0.0.0.0 -n vault svc/vault-ui 8200:8200

```
- Apply Domain
```sh

# Edit and run again
kubectl apply -f bookinfo/gateway-domain/shared-gateway.yaml

kubectl apply -f bookinfo/gateway-domain/vault-httproute.yaml
kubectl describe httproute vault-route -n istio-system

### Add RECORDS ON Cloudflare

kubectl apply -f bookinfo/gateway-domain/vault-certificate.yaml
kubectl get certificate -n default

```
### Install Vault CLI on Ubuntu
[Install Vault CLI on Ubuntu](https://developer.hashicorp.com/vault/install)
```sh
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```
### Use Vault in BookInfo Application
```sh
helm upgrade vault hashicorp/vault \
  -n istio-system \
  --create-namespace \
  --set "server.dev.enabled=true" \
  --set "server.dev.devRootToken=root" \
  --set "ui.enabled=true" \
  --set "injector.enabled=true" \
  --set "server.extraEnvironmentVars.VAULT_ADDR=vault.hoangguruu.site"

# Check injector
kubectl get mutatingwebhookconfiguration | grep vault
kubectl get pods -A | grep -i injector

# Save secrets in Vault
secret/data/ratings
MONGO_DB_URL="mongodb+srv://devops_db_user:vVY8PYxmDuJ0BNGq@devops-on-aws.zrr4zku.mongodb.net/?appName=devops-on-aws/"

# Create Policy in Vault
vault policy write ratings-policy ratings-policy.hcl
# path "secret/data/ratings" {
#   capabilities = ["read"]
# }

# Login 
export VAULT_ADDR=https://vault.hoangguruu.site
vault login # root

vault write auth/kubernetes/role/bookinfo-ratings-v2 \
  bound_service_account_names=bookinfo-ratings-v2 \
  bound_service_account_namespaces=default \
  policies=ratings-policy \
  ttl=1h

vault read auth/kubernetes/role/bookinfo-details-v2

kubectl exec -it deploy/ratings-v2 -- sh
ls /vault/secrets
cat /vault/secrets/mongo
```

###  Setup ArgoCD

[Setup ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/)

```sh
kubectl apply -n istio-system --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Simple Setup
kubectl -n istio-system patch configmap argocd-cmd-params-cm \
  --type merge \
  -p '{"data":{"server.insecure":"true"}}'

kubectl rollout restart deployment argocd-server -n istio-system

## Username: admin
## Password:
kubectl -n istio-system get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo

# Edit and run again
kubectl apply -f bookinfo/gateway-domain/shared-gateway.yaml

kubectl apply -f bookinfo/gateway-domain/argocd-httproute.yaml
kubectl describe httproute argocd-route -n istio-system

### Add RECORDS ON Cloudflare

kubectl apply -f bookinfo/gateway-domain/argocd-certificate.yaml
kubectl get certificate -n default
```