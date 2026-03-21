# DevOps on AWS Real Project - All In One

## Setup HPA Auto Scaling and Monitoring - Alert

[Setup HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

```sh
# Default 5m to scale down
kubectl autoscale deployment productpage-v1 --cpu=50% --min=1 --max=5

# 1m to scale donw
k apply -f bookinfo/platform/hpa/hpa.yaml

kubectl get hpa

kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://ad6f4ffdc1ef444adbb8fe01273b875f-1681816667.us-east-1.elb.amazonaws.com/productpage; done"

# Delete Force when you want - If pod not terminated
kubectl delete pod load-generator --grace-period=0 --force

kubectl get hpa productpage-v1 --watch
```