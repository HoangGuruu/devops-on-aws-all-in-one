# DevOps on AWS Real Project - All In One

## Deployment Stragegy

### Setup Istio and Apply

[Setup Istio on Ubuntu](https://istio.io/latest/docs/setup/getting-started/#download)

- Download Istio
```sh
curl -L https://istio.io/downloadIstio | sh -

cd istio-1.29.1

export PATH=$PWD/bin:$PATH

```

- Install Istio

```sh
istioctl install -f bookinfo/gateway-api/demo-profile-no-gateways.yaml -y

kubectl label namespace default istio-injection=enabled
```
- Install the Kubernetes Gateway API CRDs
```sh
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
{ kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }
```
- Deploy the main application
```sh
kubectl apply -f bookinfo/platform/kube/
```
- Create a Kubernetes Gateway for the Bookinfo application:
```sh
kubectl apply -f samples/bookinfo/gateway-api/bookinfo-gateway.yaml
```
- Change the service type to ClusterIP by annotating the gateway:
```sh
kubectl annotate gateway bookinfo-gateway networking.istio.io/service-type=ClusterIP --namespace=default

kubectl get gateway
```
- Access the application
```sh
kubectl port-forward --address 0.0.0.0 svc/bookinfo-gateway  8080:80
```
### View the dashboard kiali

```sh
kubectl apply -f samples/addons/kiali.yaml
kubectl rollout status deployment/kiali -n istio-system

istioctl dashboard kiali

for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done

```
```
istioctl dashboard kiali
