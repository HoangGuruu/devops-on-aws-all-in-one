# DevOps on AWS Real Project - All In One

## Setup HPA Auto Scaling and Monitoring - Alert

[Setup HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

```sh
kubectl autoscale deployment productpage-v1 --cpu=50% --min=1 --max=10

kubectl get hpa
```