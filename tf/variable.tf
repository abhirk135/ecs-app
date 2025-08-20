variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "ark-hw-repo"
}

variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

variable "cluster_name" {
  default = "ark-hw-cluster"
}
variable "service_name" {
  default = "ark-hw-service"
}
variable "container_name" {
  default = "ark-hw-container"
}
variable "container_port" {
  default = 8080
}
variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
  default     = [
    "subnet-0c5f890519d4f7f7f",
    "subnet-029f5515fc8771089",
    "subnet-06abea096147f9567"
  ]
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
  default     = [
    "sg-0fca373cc94c770ee"
  ]
}
