# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix develop/staging/production"
  type        = string
  default     = "develop"
}
# Business Department
variable "business_department" {
  description = "Business Department in the large organization this Infrastructure belongs"
  type        = string
  default     = "DevOps"
}
