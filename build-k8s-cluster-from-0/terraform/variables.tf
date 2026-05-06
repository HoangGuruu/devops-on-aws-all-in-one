variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type_master" {
  default = "t3.medium"
}

variable "instance_type_worker" {
  default = "t3.small"
}

variable "worker_count" {
  default = 2
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "k8s-cluster-key"
}

variable "my_ip" {
  description = "Your IP address for SSH access (use 0.0.0.0/0 for any IP, not recommended for production)"
  default     = "0.0.0.0/0"
}
