# Kubernetes Cluster Network Ports Reference

## Overview
This document details all network ports configured in the security group for the Kubernetes cluster.

## Security Group Configuration

### Control Plane (Master Node)

| Port/Range | Protocol | Source | Purpose |
|------------|----------|--------|---------|
| 22 | TCP | Your IP | SSH access |
| 6443 | TCP | Your IP + Internal | Kubernetes API Server |
| 2379-2380 | TCP | Internal | etcd server client API |
| 10250 | TCP | Internal | Kubelet API |
| 10259 | TCP | Internal | kube-scheduler |
| 10257 | TCP | Internal | kube-controller-manager |

### Worker Nodes

| Port/Range | Protocol | Source | Purpose |
|------------|----------|--------|---------|
| 22 | TCP | Your IP | SSH access |
| 10250 | TCP | Internal | Kubelet API |
| 30000-32767 | TCP | Your IP | NodePort Services |

### CNI - Flannel

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 8472 | UDP | Internal | VXLAN overlay network |
| 8285 | UDP | Internal | Flannel health check |

### General

| Port/Range | Protocol | Source | Purpose |
|------------|----------|--------|---------|
| All | All | Internal (self) | Inter-node communication |
| All | All | 0.0.0.0/0 | Outbound traffic (egress) |

## Port Details

### 6443 - Kubernetes API Server
- **Required by**: kubectl, kubeadm, kubelet, external clients
- **Direction**: Inbound
- **Critical**: Yes - cluster won't function without it
- **Security**: Exposed to your IP only

### 2379-2380 - etcd
- **Required by**: kube-apiserver, etcd peers
- **Direction**: Inbound
- **Critical**: Yes - stores cluster state
- **Security**: Internal only

### 10250 - Kubelet API
- **Required by**: kube-apiserver, kubectl exec/logs
- **Direction**: Inbound
- **Critical**: Yes - node management
- **Security**: Internal only

### 10259 - kube-scheduler
- **Required by**: Health checks
- **Direction**: Inbound
- **Critical**: Yes - pod scheduling
- **Security**: Internal only

### 10257 - kube-controller-manager
- **Required by**: Health checks
- **Direction**: Inbound
- **Critical**: Yes - cluster controllers
- **Security**: Internal only

### 30000-32767 - NodePort Services
- **Required by**: External access to services
- **Direction**: Inbound
- **Critical**: No - only if using NodePort
- **Security**: Exposed to your IP only

### 8472 - Flannel VXLAN
- **Required by**: Pod-to-pod communication
- **Direction**: Inbound
- **Critical**: Yes - pod networking
- **Security**: Internal only

### 8285 - Flannel Health
- **Required by**: Flannel health checks
- **Direction**: Inbound
- **Critical**: No - monitoring only
- **Security**: Internal only

## Security Best Practices

### 1. Restrict SSH Access
```hcl
# In terraform.tfvars
my_ip = "YOUR_PUBLIC_IP/32"  # Not 0.0.0.0/0
```

### 2. API Server Access
- Keep 6443 restricted to your IP
- Use VPN for team access
- Consider AWS PrivateLink for production

### 3. NodePort Range
- Only open if using NodePort services
- Consider LoadBalancer or Ingress instead
- Restrict to specific IPs if possible

### 4. Internal Communication
- All internal traffic uses security group self-reference
- No external access to internal ports
- Encrypted with TLS where applicable

## Testing Port Connectivity

### From Local Machine
```bash
# Test API Server
curl -k https://<MASTER_IP>:6443

# Test SSH
ssh -i ~/.ssh/k8s-cluster-key.pem ubuntu@<MASTER_IP>

# Test NodePort (if service exists)
curl http://<WORKER_IP>:30080
```

### From Master Node
```bash
# Test etcd
sudo netstat -tlnp | grep 2379

# Test kubelet
curl -k https://localhost:10250/healthz

# Test scheduler
curl http://localhost:10259/healthz

# Test controller-manager
curl http://localhost:10257/healthz
```

### From Worker Node
```bash
# Test kubelet
curl -k https://localhost:10250/healthz

# Test API server connectivity
curl -k https://<MASTER_PRIVATE_IP>:6443
```

## Firewall Rules (iptables)

Kubernetes automatically creates iptables rules for:
- Service ClusterIP routing
- Pod network routing
- SNAT for outbound traffic
- NodePort forwarding

View rules:
```bash
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
```

## Network Troubleshooting

### Check Open Ports
```bash
# On master/worker
sudo netstat -tlnp
sudo ss -tlnp
```

### Test Connectivity
```bash
# From master to worker
nc -zv <WORKER_IP> 10250

# From worker to master
nc -zv <MASTER_IP> 6443
```

### Check Security Group
```bash
# List security group rules
aws ec2 describe-security-groups \
  --group-names k8s-cluster-sg \
  --query 'SecurityGroups[0].IpPermissions'
```

### Verify Flannel
```bash
# Check VXLAN interface
ip -d link show flannel.1

# Check routes
ip route show

# Test pod-to-pod
kubectl run test --image=busybox --rm -it -- ping <POD_IP>
```

## Production Recommendations

1. **Use Private Subnets** for worker nodes
2. **Bastion Host** for SSH access
3. **VPN/PrivateLink** for API access
4. **Network Policies** for pod-level security
5. **Service Mesh** (Istio/Linkerd) for mTLS
6. **WAF** in front of Ingress
7. **DDoS Protection** with AWS Shield

## Additional Resources

- [Kubernetes Ports and Protocols](https://kubernetes.io/docs/reference/ports-and-protocols/)
- [Flannel Networking](https://github.com/flannel-io/flannel)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
