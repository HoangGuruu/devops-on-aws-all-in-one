# Kubernetes Cluster Automation - Complete Solution

## 🎯 Overview

Fully automated Kubernetes cluster deployment on AWS EC2 using Terraform and Ansible with zero manual configuration required.

## ✨ Key Features

### 🔑 Automated SSH Key Management
- **Auto-generates** RSA 4096-bit key pair
- **Auto-creates** AWS key pair resource
- **Auto-saves** to `~/.ssh/k8s-cluster-key.pem`
- **Auto-configures** correct permissions (0400)
- **No manual key creation needed!**

### 🌐 Default VPC Integration
- Uses existing AWS default VPC
- No custom VPC creation required
- Leverages default subnet
- Faster deployment
- Lower complexity

### 🔒 Complete Network Security
All Kubernetes required ports configured:

**Control Plane:**
- 6443 - Kubernetes API Server
- 2379-2380 - etcd
- 10250 - Kubelet API
- 10259 - kube-scheduler
- 10257 - kube-controller-manager

**Worker Nodes:**
- 10250 - Kubelet API
- 30000-32767 - NodePort Services

**CNI (Flannel):**
- 8472 (UDP) - VXLAN overlay
- 8285 (UDP) - Health check

**Management:**
- 22 - SSH access
- All internal traffic between nodes

### 🚀 One-Command Deployment
```bash
./deploy.sh
```

Everything is automated:
1. ✅ SSH key generation
2. ✅ Infrastructure provisioning
3. ✅ Security group configuration
4. ✅ Kubernetes installation
5. ✅ Cluster initialization
6. ✅ Worker node joining

## 📁 Project Structure

```
k8s-cluster-automation/
├── terraform/
│   ├── main.tf                    # Infrastructure + Key generation
│   ├── variables.tf               # Configurable parameters
│   ├── outputs.tf                 # IPs and SSH commands
│   ├── inventory.tpl              # Ansible inventory template
│   └── terraform.tfvars.example   # Configuration example
├── ansible/
│   ├── playbook.yml               # Complete K8s setup
│   └── ansible.cfg                # Ansible configuration
├── deploy.sh                      # One-command deployment
├── cleanup.sh                     # Resource cleanup
├── README.md                      # Full documentation
├── QUICKSTART.md                  # Quick reference
├── NETWORK_PORTS.md               # Port documentation
├── ARCHITECTURE.md                # Architecture diagrams
└── .gitignore                     # Exclude sensitive files
```

## 🎬 Quick Start

### Prerequisites
```bash
# Install AWS CLI
aws --version

# Configure credentials
aws configure

# Install Terraform
terraform --version

# Install Ansible
ansible --version
```

### Deploy
```bash
cd k8s-cluster-automation

# Option 1: One-command deployment
chmod +x deploy.sh
./deploy.sh

# Option 2: Step-by-step
cd terraform
terraform init
terraform apply -auto-approve

cd ../ansible
ansible-playbook playbook.yml
```

### Access
```bash
# Get SSH command
cd terraform
terraform output ssh_command_master

# Or manually
ssh -i ~/.ssh/k8s-cluster-key.pem ubuntu@<MASTER_IP>

# Verify cluster
kubectl get nodes
kubectl get pods -A
```

## 🔧 Configuration

### Minimal (Use Defaults)
No configuration needed! Just run `./deploy.sh`

### Custom Configuration
Create `terraform/terraform.tfvars`:

```hcl
aws_region           = "us-east-1"
instance_type_master = "t3.medium"
instance_type_worker = "t3.small"
worker_count         = 2
key_name             = "k8s-cluster-key"
my_ip                = "YOUR_IP/32"  # Recommended for security
```

## 📊 What Gets Created

### AWS Resources
| Resource | Details |
|----------|---------|
| SSH Key Pair | Auto-generated RSA 4096 |
| Security Group | All K8s ports configured |
| Master Node | t3.medium, Ubuntu 22.04 |
| Worker Nodes | 2x t3.small, Ubuntu 22.04 |
| VPC | Uses default VPC |

### Kubernetes Components
| Component | Version/Type |
|-----------|--------------|
| Kubernetes | 1.28 |
| Container Runtime | containerd |
| CNI Plugin | Flannel |
| Pod Network | 10.244.0.0/16 |

## 💰 Cost Estimate

| Resource | Monthly Cost (us-east-1) |
|----------|--------------------------|
| t3.medium (Master) | ~$30 |
| t3.small x2 (Workers) | ~$30 |
| **Total** | **~$60/month** |

## 🧪 Testing

### Deploy Test Application
```bash
# Create deployment
kubectl create deployment nginx --image=nginx

# Expose as NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# Get service details
kubectl get svc nginx

# Access from browser
http://<WORKER_IP>:<NODE_PORT>
```

### Verify Cluster Health
```bash
# Check nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Check component status
kubectl get cs

# Check cluster info
kubectl cluster-info
```

## 🧹 Cleanup

```bash
# Option 1: Use cleanup script
chmod +x cleanup.sh
./cleanup.sh

# Option 2: Manual
cd terraform
terraform destroy -auto-approve
```

**Removes:**
- All EC2 instances
- Security group
- AWS key pair
- Ansible inventory

**Keeps:**
- SSH key in `~/.ssh/` (manual deletion if needed)

## 🔍 Troubleshooting

### Can't Connect to Instances
```bash
# Check your IP
curl ifconfig.me

# Update terraform.tfvars
my_ip = "YOUR_IP/32"

# Reapply
terraform apply -auto-approve
```

### Nodes Not Ready
```bash
# SSH to node
ssh -i ~/.ssh/k8s-cluster-key.pem ubuntu@<NODE_IP>

# Check kubelet
sudo systemctl status kubelet
sudo journalctl -u kubelet -f

# Check containerd
sudo systemctl status containerd
```

### Pods Not Starting
```bash
# Describe pod
kubectl describe pod <POD_NAME>

# Check logs
kubectl logs <POD_NAME>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 📚 Documentation

- **README.md** - Complete documentation
- **QUICKSTART.md** - Quick reference guide
- **NETWORK_PORTS.md** - Detailed port documentation
- **ARCHITECTURE.md** - Architecture diagrams

## 🔐 Security Best Practices

1. **Restrict SSH Access**
   ```hcl
   my_ip = "YOUR_IP/32"  # Not 0.0.0.0/0
   ```

2. **Use IAM Roles**
   - Attach IAM role to EC2 instances
   - Avoid hardcoded credentials

3. **Enable Encryption**
   - EBS encryption at rest
   - TLS for all K8s components

4. **Network Policies**
   ```bash
   kubectl apply -f network-policy.yaml
   ```

5. **RBAC**
   ```bash
   kubectl create serviceaccount myapp
   kubectl create rolebinding myapp-binding
   ```

## 🚀 Next Steps

### 1. Install Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

### 2. Set Up Monitoring
```bash
# Prometheus & Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
```

### 3. Configure Storage
```bash
# EBS CSI Driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```

### 4. Implement CI/CD
- Jenkins
- GitLab CI
- GitHub Actions
- ArgoCD

### 5. Service Mesh
- Istio
- Linkerd
- Consul

## 🎓 Learning Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Flannel Networking](https://github.com/flannel-io/flannel)

## 🤝 Contributing

Improvements welcome:
- Add multi-master HA setup
- Implement auto-scaling
- Add monitoring stack
- Create Helm charts
- Add network policies

## 📝 License

MIT License - Free to use and modify

## 🆘 Support

Issues? Check:
1. AWS credentials configured
2. Terraform/Ansible installed
3. Default VPC exists
4. Security group rules applied
5. Instances have public IPs

## ⚡ Performance Tips

1. **Use Larger Instances** for production
2. **Enable EBS Optimization**
3. **Use Placement Groups** for low latency
4. **Implement Pod Disruption Budgets**
5. **Configure Resource Limits**

## 🌟 Features Summary

| Feature | Status |
|---------|--------|
| Auto SSH Key Generation | ✅ |
| Default VPC Support | ✅ |
| Complete Port Configuration | ✅ |
| One-Command Deployment | ✅ |
| Ansible Automation | ✅ |
| Flannel CNI | ✅ |
| Ubuntu 22.04 | ✅ |
| Kubernetes 1.28 | ✅ |
| containerd Runtime | ✅ |
| Auto Inventory Generation | ✅ |
| SSH Command Output | ✅ |
| Cleanup Script | ✅ |
| Documentation | ✅ |

---

**Ready to deploy your Kubernetes cluster?**

```bash
cd k8s-cluster-automation
./deploy.sh
```

**That's it! Your cluster will be ready in ~10 minutes.** 🚀
