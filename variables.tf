variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for tagging and naming resources"
  type        = string
  default     = "spatial-registry"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository used to store the Docker image"
  type        = string
  default     = "spatial-registry-api"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "spatial-registry-cluster"
}

variable "container_port" {
  description = "Port exposed by the Spring Boot REST API container"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units for the ECS Fargate task"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Memory (MiB) for the ECS Fargate task"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Desired number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "container_image_tag" {
  description = "Tag of the container image to deploy from ECR"
  type        = string
  default     = "latest"
}
