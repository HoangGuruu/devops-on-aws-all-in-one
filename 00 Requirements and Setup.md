# DevOps on AWS Real Project - All In One

## Containerization Microservices Project

### Check Ubuntu Machine

```sh
uname -m
# x86_64 → your machine is x86-64 (Intel/AMD)
# aarch64 → your machine is ARM64 (Apple Silicon, AWS Graviton, etc.)
```

### Install Docker on Ubuntu

- You can reference this way
[Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- Or this way
```sh
# Install Docker by script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

docker --version

sudo usermod -aG docker $USER
sudo chmod 660 /var/run/docker.sock
newgrp docker

```

### Install Terraform on Ubuntu
- You can reference this way
[Install Terraform on Ubuntu](https://developer.hashicorp.com/terraform/install)
```sh
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Install AWS CLI on Ubuntu
- You can reference this way
[Install AWS CLI on Ubuntu](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt update
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
```
### Install eksctl on Ubuntu
- You can reference this way
[Install eksctl on Ubuntu](https://docs.aws.amazon.com/eks/latest/eksctl/installation.html)
```sh
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl
```
### Install kubectl on Ubuntu
- You can reference this way
[Install kubectl on Ubuntu](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux)
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
# and then append (or prepend) ~/.local/bin to $PATH

kubectl version --client
```
### Install Helm on Ubuntu
- You can reference this way
[Install Helm on Ubuntu](https://helm.sh/docs/intro/install/)
```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```


