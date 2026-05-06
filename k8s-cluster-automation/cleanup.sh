#!/bin/bash

set -e

echo "========================================="
echo "Kubernetes Cluster Cleanup Script"
echo "========================================="

read -p "Are you sure you want to destroy the cluster? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

cd terraform
terraform destroy -auto-approve

cd ../ansible
rm -f inventory.ini join-command.sh

echo ""
echo "Cleanup complete!"
