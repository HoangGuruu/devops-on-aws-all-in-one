# Quick Start Guide - Kubernetes Cluster Automation

## 🚀 Deploy in 3 Commands

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform installed
- Ansible installed

### Deploy Everything

```bash
# 1. Navigate to project
cd k8s-cluster-automation

# 2. Deploy infrastructure (creates key pair automatically)
cd terraform
terraform init
terraform apply -auto-approve

# 3. Configure Kubernetes cluster
cd ../ansible
ansible-playbook playbook.yml

ansible-playbook -i inventory.ini install-k8s.yml \
  -e kubernetes_minor_version=1.34 \
  -e kubernetes_version=1.34.0-1.1

ansible-playbook -i inventory.ini upgrade.yml \
  -e kubernetes_minor_version=1.35
```

### Access Your Cluster

```bash
# Get SSH command from Terraform output
cd ../terraform
terraform output ssh_command_master

# Or manually
ssh -i ~/.ssh/k8s-cluster-key.pem ubuntu@<MASTER_IP>

# Check cluster
kubectl get nodes
kubectl get pods -A


```

## 🔑 SSH Key Automation

**Terraform automatically:**
- ✅ Generates RSA 4096-bit key pair
- ✅ Creates AWS key pair resource
- ✅ Saves private key to `~/.ssh/k8s-cluster-key.pem`
- ✅ Sets correct permissions (0400)
- ✅ Configures Ansible to use the key

**No manual key creation needed!**

## 🌐 Network Ports Configured

### Master Node
- **22** - SSH
- **6443** - Kubernetes API Server
- **2379-2380** - etcd
- **10250** - Kubelet API
- **10259** - kube-scheduler
- **10257** - kube-controller-manager

### Worker Nodes
- **22** - SSH
- **10250** - Kubelet API
- **30000-32767** - NodePort Services

### CNI (Flannel)
- **8472** - VXLAN overlay network
- **8285** - Health check

### Internal
- **All traffic** between cluster nodes

## 📋 What Gets Created

### AWS Resources
- ✅ SSH Key Pair (auto-generated)
- ✅ Security Group (all K8s ports)
- ✅ 1 Master EC2 (t3.medium)
- ✅ 2 Worker EC2 (t3.small)
- ✅ Uses Default VPC

### Kubernetes Components
- ✅ containerd runtime
- ✅ Kubernetes 1.28
- ✅ Flannel CNI
- ✅ Fully configured cluster

## 🎯 Customization

Edit `terraform/terraform.tfvars`:

```hcl
aws_region           = "us-east-1"
instance_type_master = "t3.medium"
instance_type_worker = "t3.small"
worker_count         = 2
key_name             = "k8s-cluster-key"
my_ip                = "YOUR_IP/32"  # Recommended for security
```

## 🧹 Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```

This removes:
- All EC2 instances
- Security group
- AWS key pair
- Local key files remain in `~/.ssh/`

## 💡 Tips

1. **Security**: Change `my_ip` from `0.0.0.0/0` to your IP
2. **Cost**: ~$60/month for default setup
3. **Region**: Change `aws_region` if needed
4. **Workers**: Adjust `worker_count` as needed

## 🔍 Verify Deployment

```bash
# Check Terraform outputs
terraform output

# Test SSH
ssh -i ~/.ssh/k8s-cluster-key.pem ubuntu@<MASTER_IP>

# Check nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Deploy test app
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get svc nginx
```

## 📞 Troubleshooting

**Issue**: Can't connect via SSH
```bash
# Check security group allows your IP
curl ifconfig.me
# Update terraform.tfvars with your IP
```

**Issue**: Nodes not ready
```bash
# Check kubelet status
sudo systemctl status kubelet
# Check logs
sudo journalctl -u kubelet -f
```

**Issue**: Pods not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

## 🎓 Next Steps

1. Install Ingress Controller
2. Set up monitoring (Prometheus/Grafana)
3. Configure persistent storage
4. Implement network policies
5. Set up CI/CD pipeline

---

**Ready to deploy?** Just run the 3 commands above! 🚀
