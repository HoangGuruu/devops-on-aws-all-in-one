# DevOps on AWS Real Project - All In One

## Custom Domain

### Setup Domain from vendor to Cloudflare

### Setup Ingress Nginx Controller

- You can reference this way
[Setup Ingress Nginx Controller](https://kubernetes.github.io/ingress-nginx/deploy/)

```sh
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

helm uninstall ingress-nginx --namespace ingress-nginx


```
#### Installing cert-manager
- You can reference this way
[Installing cert-manager ](https://cert-manager.io/docs/installation/)

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Uninstall
helm uninstall cert-manager --namespace cert-manager

```

#### Create file cluster-issuer.yaml:
```sh
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: hoangguruu@gmail.com 
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

```sh
# The ClusterIssuer defines how cert-manager will request certificates
kubectl apply -f eks/cluster-issuer.yaml
kubectl get clusterissuer
```
#### Run Nginx Testing App
```sh
kubectl apply -f eks/app-test.yaml
kubectl get pod
kubectl get svc
kubectl get ingress
kubectl get certificate -A
kubectl describe certificate hoangguruu-id-vn-tls
```
##### Notice: 
Cloudflare: SSL/TLS encryption - Current encryption mode: Full

