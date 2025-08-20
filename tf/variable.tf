variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "ark-repo"
}

variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "ark-cluster"
}

variable "service_name" {
  description = "ECS service name"
  type        = string
  default     = "ark-service"
}

variable "container_name" {
  description = "ECS container name"
  type        = string
  default     = "ark-container"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8081
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
  # Default can be empty, or set via terraform.tfvars after creation
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
  # Default can be empty, or set via terraform.tfvars after creation
  default     = []
}