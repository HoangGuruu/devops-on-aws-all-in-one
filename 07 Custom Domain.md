# DevOps on AWS Real Project - All In One

## Custom Domain

### 1 Setup Domain from vendor to Cloudflare
- When Domain is actived ( Waiting )

### 2 Setup cert-manager
[Setup cert-manager](https://cert-manager.io/docs/installation/kubectl/)

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml
# Enable gateway-api to use 
kubectl patch deployment cert-manager -n cert-manager --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'

kubectl get pods --namespace cert-manager

kubectl get deployment cert-manager -n cert-manager --type='json' | grep enable
```
## 3 Apply Gateway and httproute 
```sh
kubectl apply -f bookinfo/gateway-domain/shared-gateway.yaml
kubectl get gateway
# Bookinfo
kubectl apply -f bookinfo/gateway-domain/bookinfo-httproute.yaml
kubectl describe httproute bookinfo-route -n istio-system
# Grafana
kubectl apply -f bookinfo/gateway-domain/grafana-httproute.yaml
kubectl describe httproute grafana-route -n istio-system
```
### 4 Add RECORDS ON Cloudflare

### 5 Create ClusterIssuer with Let’s Encrypt
- Apply `clusterissuer.yaml`
```sh
kubectl apply -f bookinfo/gateway-domain/0-clusterissuer.yaml
k get clusterissuer
```

### 6 Create Certificate 
```sh
# Bookinfo
kubectl apply -f bookinfo/gateway-domain/bookinfo-certificate.yaml
kubectl get certificate -n default
# Check status Progress
kubectl get certificaterequest,order,challenge -n default

# Grafana
kubectl apply -f bookinfo/gateway-domain/grafana-certificate.yaml
kubectl get certificate -n istio-system
# Check status Progress
kubectl get certificaterequest,order,challenge -n istio-system

```
### 7 Setup Config with Grafana
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

kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml
kubectl delete namespace cert-manager --ignore-not-found=true
``` 