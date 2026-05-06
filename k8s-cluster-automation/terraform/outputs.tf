output "master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_public_ips" {
  value = aws_instance.k8s_worker[*].public_ip
}

output "master_private_ip" {
  value = aws_instance.k8s_master.private_ip
}

output "worker_private_ips" {
  value = aws_instance.k8s_worker[*].private_ip
}

output "ssh_key_path" {
  value = "~/.ssh/${var.key_name}.pem"
}

output "ssh_command_master" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.k8s_master.public_ip}"
}

output "key_name" {
  value = var.key_name
}

output "lbc_role_arn" {
  value       = aws_iam_role.lbc.arn
  description = "IAM role ARN for the AWS Load Balancer Controller"
}

output "cluster_name" {
  value = var.cluster_name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
