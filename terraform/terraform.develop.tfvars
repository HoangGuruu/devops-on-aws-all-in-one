# General Configuration
aws_region          = "us-east-1"
environment         = "prod"
business_department = "devops-on-aws-all-in-one"
# VPC Configuration
vpc_name                                = "vpc-01"
vpc_cidr_block                          = "10.0.0.0/16"
vpc_public_subnets                      = ["10.0.101.0/24", "10.0.102.0/24"]
vpc_private_subnets                     = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_database_subnets                    = ["10.0.151.0/24", "10.0.152.0/24"]
vpc_create_database_subnet_group        = false
vpc_create_database_subnet_route_table  = false
vpc_enable_nat_gateway                  = false
vpc_single_nat_gateway                  = false

# EKS Cluster Configuration
cluster_name                            = "eks-01"
cluster_service_ipv4_cidr               = null            # leave null to let AWS decide
cluster_version                         = "1.35"          # example Kubernetes version
cluster_endpoint_private_access         = false
cluster_endpoint_public_access          = true
cluster_endpoint_public_access_cidrs    = ["0.0.0.0/0"]

# Node Group
node_instance_type  = "t2.medium"
node_desired_size   = 1
node_min_size       = 1
node_max_size       = 2
node_ami_type = "AL2023_x86_64_STANDARD"


