#!/bin/bash

set -e

echo "========================================="
echo "Kubernetes Cluster Deployment Script"
echo "========================================="
echo ""
echo "Features:"
echo "  ✅ Auto-generates SSH key pair"
echo "  ✅ Uses default VPC"
echo "  ✅ Configures all K8s ports"
echo "  ✅ Full cluster automation"
echo ""

# Step 1: Terraform
echo "Step 1: Deploying infrastructure with Terraform..."
cd terraform

if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found, using defaults..."
    echo "   You can create terraform.tfvars to customize settings"
fi

echo "Initializing Terraform..."
terraform init

echo "Planning infrastructure..."
terraform plan

echo "Applying infrastructure..."
terraform apply -auto-approve

echo ""
echo "✅ Infrastructure deployed!"
echo "📋 SSH Key saved to: ~/.ssh/k8s-cluster-key.pem"
echo ""

echo "Waiting 45 seconds for instances to be ready..."
sleep 45

cd ..

# Step 2: Ansible
echo ""
echo "Step 2: Configuring Kubernetes cluster with Ansible..."
cd ansible

if [ ! -f "inventory.ini" ]; then
    echo "❌ ERROR: inventory.ini not found!"
    echo "Terraform should have generated it."
    exit 1
fi

echo "Testing connectivity to all nodes..."
for i in {1..3}; do
    if ansible all -m ping; then
        break
    else
        if [ $i -eq 3 ]; then
            echo "❌ Cannot connect to nodes. Check security group and SSH key."
            exit 1
        fi
        echo "Retrying in 10 seconds..."
        sleep 10
    fi
done

echo ""
echo "Running Kubernetes setup playbook..."
echo "This will take 5-10 minutes..."
ansible-playbook playbook.yml

cd ..

echo ""
echo "========================================="
echo "🎉 Deployment Complete!"
echo "========================================="
echo ""
echo "📊 Cluster Information:"
cd terraform
terraform output
echo ""
echo "🔑 SSH Access:"
terraform output -raw ssh_command_master
echo ""
echo ""
echo "📝 Next Steps:"
echo "1. SSH to master node (command above)"
echo "2. Run: kubectl get nodes"
echo "3. Run: kubectl get pods -A"
echo "4. Deploy your applications!"
echo ""
echo "📚 Documentation:"
echo "  - QUICKSTART.md - Quick reference"
echo "  - NETWORK_PORTS.md - Port details"
echo "  - README.md - Full documentation"
echo ""
