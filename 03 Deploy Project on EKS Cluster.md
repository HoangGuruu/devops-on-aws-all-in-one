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
# Case: mongodb on the same namespace with deployment
kubectl create secret generic ratings-mongodb-secret \
  --from-literal=MONGO_DB_URL='mongodb://mongodb:27017/test'

# Check secret
k get secret ratings-mongodb-secret

# MYSQL
kubectl create secret generic ratings-mysql-password \
  --from-literal=MYSQL_DB_PASSWORD='password'
```

- Deploy Complete Application
```sh
# Deploy application 
kubectl apply -f bookinfo/platform/kube/
# Check access in another terminal
kubectl port-forward svc/productpage 9080:9080
# Check access out local
kubectl port-forward --address 0.0.0.0 svc/productpage 9080:9080
# --> Access http://number-ip-public-ubuntu:9080/
# Load Many times to check 3 version
```
- ( Optional ) Scale to test only 1 version - Access browser again
```sh
kubectl scale deploy reviews-v1 --replicas=1
kubectl scale deploy reviews-v2 --replicas=0
kubectl scale deploy reviews-v3 --replicas=0
```

```sh
# Check Database MongoDB
kubectl exec -it mongodb-v1-69b68dbd4f-qfpsj -- sh

mongosh

show dbs

use test

show collections

db.ratings.find().pretty()


# Check Database MySQL

kubectl exec -it mysqldb-v1-5dbbdd544-s677b -- sh

mysql -uroot -ppassword

SHOW DATABASES;

USE test;

SHOW TABLES;

SELECT * FROM ratings;

```



