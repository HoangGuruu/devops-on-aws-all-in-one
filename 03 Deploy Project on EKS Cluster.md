# DevOps on AWS Real Project - All In One

## Deploy Project on EKS Cluster

### Deploy Book App version 1 

```sh
# Deploy application 
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
# Check access in another terminal
kubectl port-forward svc/productpage 9080:9080
# Check access out local
kubectl port-forward --address 0.0.0.0 svc/productpage 9080:9080
# --> Access http://number-ip-public-ubuntu:9080/
```





