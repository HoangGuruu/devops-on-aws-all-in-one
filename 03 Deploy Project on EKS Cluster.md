# DevOps on AWS Real Project - All In One

## Deploy Project on EKS Cluster

### Deploy Book App 

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

### Setup MongoDB Cloud

- You can check here 
[MongoDB Cloud](https://cloud.mongodb.com/)

- Create collection ratings 

- Add data

```sh
[
  { "rating": 5 },
  { "rating": 2 }
]
```
- Setup secret again
```sh
kubectl create secret generic ratings-mongodb-secret \
  --from-literal=MONGO_DB_URL='mongodb+srv://devops_db_user:vVY8PYxmDuJ0BNGq@devops-on-aws.zrr4zku.mongodb.net/?appName=devops-on-aws'
```
- Setup Access to test on MongoDB
```sh
0.0.0.0/0
```

### Setup RDS MySQL
- Setup mysql-client to access
```sh
sudo apt update
sudo apt install mysql-client -y
```

- Connect to MySQL
```sh
mysql -h mydb.abc123.ap-southeast-1.rds.amazonaws.com -P 3306 -u admin -p
```

- Add data
```sh
CREATE DATABASE test;
USE test;

CREATE TABLE `ratings` (
  `ReviewID` INT NOT NULL,
  `Rating` INT,
  PRIMARY KEY (`ReviewID`)
);
INSERT INTO ratings (ReviewID, Rating) VALUES (1, 4);
INSERT INTO ratings (ReviewID, Rating) VALUES (2, 1);


SELECT * FROM ratings;
```
- Create again secret
```sh
# MYSQL
kubectl create secret generic ratings-mysql-password \
  --from-literal=MYSQL_DB_PASSWORD='password'

```