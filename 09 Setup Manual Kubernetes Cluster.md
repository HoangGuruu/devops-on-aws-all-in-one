# DevOps on AWS Real Project - All In One

## Setup Manual Kubernetes Cluster

###  Setup Vault
[Setup Vault](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide)

# Kubernetes Cluster Architecture

## Infrastructure Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Default VPC                          │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Security Group: k8s-cluster-sg                 │ │
│  │                                                              │ │
│  │  Inbound Rules:                                             │ │
│  │  • 22 (SSH)           ← Your IP                             │ │
│  │  • 6443 (K8s API)     ← Your IP                             │ │
│  │  • 2379-2380 (etcd)   ← Internal                            │ │
│  │  • 10250 (kubelet)    ← Internal                            │ │
│  │  • 10257,10259        ← Internal                            │ │
│  │  • 30000-32767        ← Your IP (NodePort)                  │ │
│  │  • 8472,8285 (UDP)    ← Internal (Flannel)                  │ │
│  │  • All traffic        ← Self (Internal)                     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    Master Node (t3.medium)                   ││
│  │  ┌────────────────────────────────────────────────────────┐ ││
│  │  │  Control Plane Components:                              │ ││
│  │  │  • kube-apiserver      (port 6443)                      │ ││
│  │  │  • etcd                (port 2379-2380)                 │ ││
│  │  │  • kube-scheduler      (port 10259)                     │ ││
│  │  │  • kube-controller-mgr (port 10257)                     │ ││
│  │  │  • kubelet             (port 10250)                     │ ││
│  │  │  • containerd          (runtime)                        │ ││
│  │  │  • flannel             (CNI)                            │ ││
│  │  └────────────────────────────────────────────────────────┘ ││
│  │  Public IP: x.x.x.x                                          ││
│  │  Private IP: 10.0.x.x                                        ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                   Worker Node 1 (t3.small)                   ││
│  │  ┌────────────────────────────────────────────────────────┐ ││
│  │  │  Node Components:                                       │ ││
│  │  │  • kubelet             (port 10250)                     │ ││
│  │  │  • kube-proxy          (iptables)                       │ ││
│  │  │  • containerd          (runtime)                        │ ││
│  │  │  • flannel             (CNI)                            │ ││
│  │  │  • Application Pods                                     │ ││
│  │  └────────────────────────────────────────────────────────┘ ││
│  │  Public IP: x.x.x.x                                          ││
│  │  Private IP: 10.0.x.x                                        ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                   Worker Node 2 (t3.small)                   ││
│  │  ┌────────────────────────────────────────────────────────┐ ││
│  │  │  Node Components:                                       │ ││
│  │  │  • kubelet             (port 10250)                     │ ││
│  │  │  • kube-proxy          (iptables)                       │ ││
│  │  │  • containerd          (runtime)                        │ ││
│  │  │  • flannel             (CNI)                            │ ││
│  │  │  • Application Pods                                     │ ││
│  │  └────────────────────────────────────────────────────────┘ ││
│  │  Public IP: x.x.x.x                                          ││
│  │  Private IP: 10.0.x.x                                        ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                   │
└─────────────────────────────────────────────────────────────────┘

                              ▲
                              │
                              │ SSH (22)
                              │ K8s API (6443)
                              │ NodePort (30000-32767)
                              │
                        ┌─────┴─────┐
                        │  Your PC  │
                        │  kubectl  │
                        └───────────┘
```

## Network Flow

### Pod-to-Pod Communication (Flannel VXLAN)
```
┌──────────┐                                    ┌──────────┐
│  Pod A   │                                    │  Pod B   │
│ Worker 1 │                                    │ Worker 2 │
└────┬─────┘                                    └─────┬────┘
     │                                                │
     │ 10.244.1.5                                     │ 10.244.2.5
     │                                                │
     ▼                                                ▼
┌─────────────┐                              ┌─────────────┐
│  flannel.1  │◄────────VXLAN (8472)────────►│  flannel.1  │
│   Worker 1  │                              │   Worker 2  │
└─────────────┘                              └─────────────┘
```

### External Access to Service
```
┌───────────┐
│  Client   │
└─────┬─────┘
      │
      │ HTTP Request
      │ http://worker-ip:30080
      ▼
┌─────────────────┐
│  Worker Node    │
│  (NodePort)     │
└────────┬────────┘
         │
         │ iptables DNAT
         │
         ▼
    ┌────────┐
    │  Pod   │
    │ :8080  │
    └────────┘
```

### kubectl Command Flow
```
┌──────────┐
│ kubectl  │
│ (Local)  │
└────┬─────┘
     │
     │ HTTPS (6443)
     │ + Client Cert
     ▼
┌─────────────────┐
│  kube-apiserver │
│  (Master Node)  │
└────────┬────────┘
         │
         ├──► etcd (read/write state)
         │
         ├──► kube-scheduler (assign pods)
         │
         ├──► kube-controller-manager (reconcile)
         │
         └──► kubelet (via 10250)
```

## Automation Flow

```
┌──────────────────────────────────────────────────────────────┐
│                     Deployment Process                        │
└──────────────────────────────────────────────────────────────┘

1. Terraform Phase
   ├─► Generate TLS private key (RSA 4096)
   ├─► Create AWS key pair
   ├─► Save key to ~/.ssh/k8s-cluster-key.pem
   ├─► Create security group (all K8s ports)
   ├─► Launch master EC2 instance
   ├─► Launch worker EC2 instances
   └─► Generate Ansible inventory

2. Ansible Phase
   ├─► Install containerd on all nodes
   ├─► Configure kernel modules & sysctl
   ├─► Install Kubernetes packages
   ├─► Initialize master (kubeadm init)
   ├─► Install Flannel CNI
   ├─► Generate join command
   └─► Join workers to cluster

3. Result
   └─► Fully functional K8s cluster
```

## Component Versions

- **OS**: Ubuntu 22.04 LTS
- **Kubernetes**: 1.28
- **Container Runtime**: containerd (latest)
- **CNI**: Flannel (latest)
- **Pod Network CIDR**: 10.244.0.0/16

## Resource Allocation

| Component | Instance Type | vCPU | RAM | Storage |
|-----------|---------------|------|-----|---------|
| Master    | t3.medium     | 2    | 4GB | 20GB    |
| Worker 1  | t3.small      | 2    | 2GB | 20GB    |
| Worker 2  | t3.small      | 2    | 2GB | 20GB    |
| **Total** |               | 6    | 8GB | 60GB    |

## High Availability Considerations

For production, consider:

```
┌─────────────────────────────────────────────────────────────┐
│                    Production Architecture                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Load Balancer (ALB/NLB)                                     │
│         │                                                     │
│         ├──► Master 1 (AZ-1)                                 │
│         ├──► Master 2 (AZ-2)                                 │
│         └──► Master 3 (AZ-3)                                 │
│                                                               │
│  External etcd Cluster                                       │
│         ├──► etcd-1 (AZ-1)                                   │
│         ├──► etcd-2 (AZ-2)                                   │
│         └──► etcd-3 (AZ-3)                                   │
│                                                               │
│  Worker Nodes (Auto Scaling Group)                           │
│         ├──► Workers in AZ-1                                 │
│         ├──► Workers in AZ-2                                 │
│         └──► Workers in AZ-3                                 │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│                      Security Stack                          │
├─────────────────────────────────────────────────────────────┤
│  Layer 1: AWS Security Group (Network Firewall)             │
│  Layer 2: TLS Encryption (API Server, etcd)                 │
│  Layer 3: RBAC (Role-Based Access Control)                  │
│  Layer 4: Network Policies (Pod-level firewall)             │
│  Layer 5: Pod Security Standards                            │
│  Layer 6: Secrets Encryption at Rest                        │
└─────────────────────────────────────────────────────────────┘
```

- [Kubernetes Ports and Protocols](https://kubernetes.io/docs/reference/ports-and-protocols/)
- [Flannel Networking](https://github.com/flannel-io/flannel)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)

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
