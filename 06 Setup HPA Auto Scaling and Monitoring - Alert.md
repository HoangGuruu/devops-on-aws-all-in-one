# DevOps on AWS Real Project - All In One

## Metric Servers
- You can reference this way
[Setup Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

kubectl get deployment -n kube-system | grep metrics-server
kubectl top node
```
## Setup HPA Auto Scaling and Monitoring - Alert

[Setup HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

```sh
# Change Deployment to HPA
k apply -f bookinfo/platform/hpa/productpage-hpa-limit-resource.yaml


# Default 5m to scale down
# kubectl autoscale deployment productpage-v1 --cpu=50% --min=1 --max=5

# 1m to scale donw
k apply -f bookinfo/platform/hpa/hpa.yaml

kubectl get hpa

kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://a6d292b799c5a46228d5f015989a8a52-1959528387.us-east-1.elb.amazonaws.com/productpage; done"

# Delete Force when you want - If pod not terminated
kubectl delete pod load-generator --grace-period=0 --force

kubectl get hpa productpage-v1 --watch
```

## Setup Dashboard to check CPU

[Webhook API Slack](https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks/)

- Check Datasource Prometheus `container_cpu_usage_seconds_total`

```sh
sum by (pod) (
  rate(container_cpu_usage_seconds_total{
    namespace="default",
    pod=~"productpage-v1-.*",
    container!="POD",
    image!="",
    job="kubernetes-nodes-cadvisor"
  }[2m])
)

```
- Add to Dashboard

## Setup Alert when CPU > 100%

- Setup Slack Connection

- Query Pod to check CPU
```sh
sum by (pod) (
  rate(container_cpu_usage_seconds_total{
    namespace="default",
    pod=~"productpage-v1-.*",
    container!="POD",
    image!="",
    job="kubernetes-nodes-cadvisor"
  }[2m])
) * 1000

```
