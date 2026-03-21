# DevOps on AWS Real Project - All In One

## Service Mesh and Observability
```sh
# Count Pods in Cluster
kubectl get pod -A --no-headers | wc -l
```

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
kubectl port-forward --address 0.0.0.0 svc/bookinfo-gateway-istio  8080:80
```
### View the dashboard kiali

```sh
kubectl apply -f samples/addons/kiali.yaml
kubectl rollout status deployment/kiali -n istio-system

kubectl -n istio-system port-forward --address 0.0.0.0 svc/kiali 20001:20001

for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done

```

```sh

kubectl port-forward --address 0.0.0.0 svc/bookinfo-gateway-istio  8080:80
kubectl port-forward --address 0.0.0.0 svc/kiali -n istio-system 8081:20001
kubectl port-forward --address 0.0.0.0 svc/grafana -n istio-system 8082:3000
kubectl port-forward --address 0.0.0.0 svc/prometheus -n istio-system  8083:9090
```