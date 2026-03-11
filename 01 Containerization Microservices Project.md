# DevOps on AWS Real Project - All In One

## Containerization Microservices Project

### dockercompose 
```sh
docker compose up -d
docker compose up -d --build # Have change and want to build again
docker ps
docker ps -a
docker images ls
docker logs mongodb
docker logs mysql
docker logs details
docker logs ratings
docker logs reviews
docker logs productpage
docker volume ls
```

```sh
version: "3.9"

name: devops-on-aws-all-in-one

services:
  # ---------- Databases ----------
  mongodb:
    build:
      context: ./mongodb
    container_name: mongodb
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    networks: [app-net]

  mysql:
    build:
      context: ./mysql
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-root123}
      MYSQL_DATABASE: ${MYSQL_DATABASE:-reviews}
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    networks: [app-net]

  # ---------- Microservices ----------
  details:
    build:
      context: ./details
      args:
        service_version: ${DETAILS_VERSION:-v1}
        enable_external_book_service: ${ENABLE_EXTERNAL_BOOK_SERVICE:-false}
    container_name: details
    environment:
      SERVICE_VERSION: ${DETAILS_VERSION:-v1}
      ENABLE_EXTERNAL_BOOK_SERVICE: ${ENABLE_EXTERNAL_BOOK_SERVICE:-false}
    expose:
      - "9080"
    depends_on:
      - mongodb
      - mysql
    restart: always
    networks: [app-net]

  ratings:
    build:
      context: ./ratings
      args:
        service_version: ${RATINGS_VERSION:-v1}
    container_name: ratings
    environment:
      SERVICE_VERSION: ${RATINGS_VERSION:-v1}
      # If code use connection string default, hostname is "mongodb"
      MONGO_DB_URL: ${MONGO_DB_URL:-mongodb://mongodb:27017/test}
      # MONGO_PORT: ${MONGO_PORT:-27017}
    expose:
      - "9080"
    depends_on:
      - mongodb
    restart: always
    networks: [app-net]

  reviews:
    build:
      context: ./reviews
      args:
        service_version: ${REVIEWS_VERSION:-v1}
        enable_ratings: ${ENABLE_RATINGS:-false}
        star_color: ${STAR_COLOR:-black}
    container_name: reviews
    environment:
      SERVICE_VERSION: ${REVIEWS_VERSION:-v1}
      ENABLE_RATINGS: ${ENABLE_RATINGS:-false}
      STAR_COLOR: ${STAR_COLOR:-black}
  
      MYSQL_HOST: ${MYSQL_HOST:-mysql}
      MYSQL_PORT: ${MYSQL_PORT:-3306}
      MYSQL_DATABASE: ${MYSQL_DATABASE:-reviews}
      MYSQL_USER: ${MYSQL_USER:-root}
      MYSQL_PASSWORD: ${MYSQL_ROOT_PASSWORD:-root123}
    expose:
      - "9080"
    depends_on:
      - mysql
    restart: always
    networks: [app-net]

  productpage:
    build:
      context: ./productpage
      args:
        flood_factor: ${FLOOD_FACTOR:-0}
    container_name: productpage
    environment:
      FLOOD_FACTOR: ${FLOOD_FACTOR:-0}
      DETAILS_HOST: ${DETAILS_HOST:-details}
      RATINGS_HOST: ${RATINGS_HOST:-ratings}
      REVIEWS_HOST: ${REVIEWS_HOST:-reviews}
    ports:
      - "9080:9080"   
    depends_on:
      - details
      - ratings
      - reviews
    restart: always
    networks: [app-net]

# ---------- Networks & Volumes ----------
networks:
  app-net:

volumes:
  mongo-data:
  mysql-data:

```

### ECR 

```sh
# Tag Images

docker tag devops-on-aws-all-in-one-details:latest 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:details-latest

docker tag devops-on-aws-all-in-one-mongodb:latest 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:mongodb-latest

docker tag devops-on-aws-all-in-one-mysql:latest 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:mysql-latest

docker tag devops-on-aws-all-in-one-productpage:latest 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:productpage-latest

docker tag devops-on-aws-all-in-one-ratings:latest 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:ratings-latest

docker tag devops-on-aws-all-in-one-reviews:latest 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:reviews-latest

# Push Command
docker push 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:details-latest

docker push 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:mongodb-latest

docker push 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:mysql-latest

docker push 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:productpage-latest

docker push 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:ratings-latest

docker push 736059458620.dkr.ecr.us-east-1.amazonaws.com/prod/devops-on-aws-all-in-one:reviews-latest
```