# DevOps on AWS Real Project - All In One

## Custom Domain

### Setup Domain from vendor to Cloudflare
- When Domain is actived ( Waiting )

### Setup cert-manager
[Setup vert-manager](https://cert-manager.io/docs/installation/kubectl/)

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml

kubectl get pods --namespace cert-manager
```
### Create ClusterIssuer with Let’s Encrypt
- Apply `clusterissuer.yaml`
```sh
kubectl apply -f clusterissuer.yaml
```
- Create Certificate
```sh
kubectl apply -f certificate.yaml

kubectl get certificate -n default
kubectl describe certificate public-sites-cert -n default
kubectl get secret public-sites-tls -n default
```

## Apply Gateway and httproute 
```sh
## All 
kubectl apply -f bookinfo/gateway-domain/gateway-domain.yaml
kubectl get gateway -n default
kubectl describe gateway public-gateway -n default

# Bookinfo
kubectl apply -f bookinfo/gateway-domain/httproute-bookinfo.yaml
kubectl describe httproute bookinfo-route -n default
# Grafana
kubectl apply -f bookinfo/gateway-domain/httproute-bookinfo.yaml
kubectl describe httproute grafana-route -n istio-system

kubectl get httproute -A

```
### Setup Config with Grafana
```sh
kubectl edit configmap grafana -n istio-system

[server]
domain = grafana.hoangguruu.site
root_url = https://grafana.hoangguruu.site/
```