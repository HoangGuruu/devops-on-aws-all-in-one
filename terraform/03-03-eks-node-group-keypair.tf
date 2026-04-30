# key_pair.tf
resource "tls_private_key" "eks_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload public key to AWS EC2
resource "aws_key_pair" "eks_key_pair" {
  key_name   = "${local.name}-eks-key"
  public_key = tls_private_key.eks_ssh_key.public_key_openssh
  tags     = local.common_tags

}

# Optional: save private key locally
resource "local_file" "eks_private_key" {
  filename        = "${path.module}/keys/${local.name}-eks-keypair.pem"
  content         = tls_private_key.eks_ssh_key.private_key_pem
  file_permission = "0600"
}


