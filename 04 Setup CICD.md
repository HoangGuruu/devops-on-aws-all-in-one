# DevOps on AWS Real Project - All In One

## Setup CI/CD

### 

- 
[Install Docker on Ubuntu](https://www.google.com)


# ArgoCD - admin - 8EURCCN7Mz0UeGdn

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

helm install argocd argo/argo-cd \
  --namespace argocd \
  --set redis.persistence.enabled=false \
  --set controller.metrics.enabled=true \
  --set repoServer.persistence.enabled=false \
  --set server.extraArgs="{--insecure}" \
  --set server.ingress.enabled=false \
  --set configs.cm."application\.instanceLabelKey"="argocd.argoproj.io/instance"


## Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: argocd.hoangguruu.id.vn
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  name: https


# 
```

## Setup Tools Platform Ecosystem

```sh
# CI/CD : Jenkins

helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --create-namespace \
  --set controller.serviceType=ClusterIP \
  --set controller.ingress.enabled=false \
  --set controller.admin.username=admin \
  --set controller.admin.password=admin123

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=ClusterIP \
  --set controller.ingress.enabled=false \
  --set controller.admin.username=admin \
  --set controller.admin.password=admin123 \
  --set persistence.enabled=false  # Không dùng Persistent Volume

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set persistence.existingClaim="" \
  --set persistence.storageClass="" \
  --set persistence.volumes[0].name=jenkins-data \
  --set persistence.volumes[0].hostPath.path="/data/jenkins" \
  --set persistence.volumeMounts[0].mountPath="/var/jenkins_home" \
  --set persistence.volumeMounts[0].name=jenkins-data


## Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod  # Nếu bạn dùng SSL, nếu không có thì bỏ dòng này
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - jenkins.hoangguruu.id.vn  # ⚠️ Thay bằng domain của bạn
    secretName: jenkins-tls
  rules:
  - host: jenkins.hoangguruu.id.vn  # ⚠️ Thay bằng domain của bạn
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: jenkins
            port:
              number: 8080


kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d && echo

# Log : ELK

# Monitoring : Grafana - Prometheus ( Custom more ) Loki
prom-operator


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

## Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: grafana.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kube-prometheus-stack-grafana
            port:
              number: 80


# Splunk

```