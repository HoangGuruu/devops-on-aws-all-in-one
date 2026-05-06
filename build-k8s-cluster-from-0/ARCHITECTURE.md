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
