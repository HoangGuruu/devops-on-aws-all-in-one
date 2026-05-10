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

output "alb_dns_name" {
  value       = aws_lb.k8s_alb.dns_name
  description = "ALB DNS name — point your domain here"
}

output "alb_url" {
  value       = "http://${aws_lb.k8s_alb.dns_name}"
  description = "HTTP URL to access your cluster apps"
}

output "nodeport_http" {
  value       = var.nodeport_http
  description = "NodePort the ALB forwards traffic to on worker nodes"
}
