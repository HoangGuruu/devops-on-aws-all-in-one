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
  --set "server.dev.enabled=true" \
  --set "ui.enabled=true" 


# helm upgrade vault hashicorp/vault \
#   -n istio-system \
#   --set "server.dev.enabled=true" \
#   --set "ui.enabled=true" \
#   --set "server.extraEnvironmentVars.VAULT_ADDR=" 

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
kubectl describe httproute vault-route -n vault

### Add RECORDS ON Cloudflare

kubectl apply -f bookinfo/gateway-domain/vault-certificate.yaml
kubectl get certificate -n default

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