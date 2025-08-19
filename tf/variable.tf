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
  type = list(string)
}
variable "security_group_ids" {
  type = list(string)
}
