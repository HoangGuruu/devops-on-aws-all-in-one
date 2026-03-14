# DevOps on AWS Real Project - All In One

## Deploy Project on EKS Cluster

### Deploy Book App version 1 

- Setup permission to pull image from ECR
```sh
kubectl create secret docker-registry ecr-secret \
  --docker-server=736059458620.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region us-east-1)" \
  --namespace=default

# Check secret
kubectl get secret ecr-secret
```
- Setup Secret Variable
```sh
kubectl create secret generic ratings-secret \
  --from-literal=MONGO_DB_URL='mongodb://username:password@mongodb:27017/test'
```


```sh
# Deploy application 
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
# Check access in another terminal
kubectl port-forward svc/productpage 9080:9080
# Check access out local
kubectl port-forward --address 0.0.0.0 svc/productpage 9080:9080
# --> Access http://number-ip-public-ubuntu:9080/
```





