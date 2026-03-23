# DevOps on AWS Real Project - All In One

## Custom Domain

### Setup Domain from vendor to Cloudflare
- When Domain is actived ( Waiting )

### Setup cert-manager
[Setup cert-manager](https://cert-manager.io/docs/installation/kubectl/)

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml
# Enable gateway-api to use 
kubectl patch deployment cert-manager -n cert-manager --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'

kubectl get pods --namespace cert-manager
```
### Create ClusterIssuer with Let’s Encrypt
- Apply `clusterissuer.yaml`
```sh
kubectl apply -f clusterissuer.yaml
k get clusterissuer
```
- Create Certificate
```sh
kubectl apply -f bookinfo-certificate.yaml

kubectl get certificate -n default
# Check status Progress
kubectl get certificaterequest,order,challenge -n default
kubectl describe certificaterequest public-sites-cert-1 -n default
kubectl get challenge -n default
kubectl describe challenge <name-challenge> -n default

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

kubectl rollout restart deployment grafana -n istio-system
kubectl rollout status deployment grafana -n istio-system
```
### Clean
```sh
kubectl delete -f bookinfo/gateway-domain/

kubectl delete certificate public-sites-cert -n default --ignore-not-found=true
kubectl delete certificaterequest,order,challenge -n default --all
kubectl delete secret public-sites-tls -n default --ignore-not-found=true
kubectl delete clusterissuer letsencrypt-prod --ignore-not-found=true

kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml
kubectl delete namespace cert-manager --ignore-not-found=true
```