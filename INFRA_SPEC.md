# Infrastructure Spec: Spatial Registry (AWS)

## 1. Objective
Provision cloud-native AWS infrastructure using Terraform to host a containerized Spring Boot REST API.

## 2. Architecture Components
- **Provider:** AWS (Region: us-east-1)
- **Networking (VPC):**
  - 1 VPC (CIDR: 10.0.0.0/16)
  - 2 Public Subnets in different Availability Zones
  - 1 Internet Gateway and corresponding route table for public access
- **Container Registry:**
  - AWS ECR repository named `spatial-registry-api` to store the Docker image
- **Compute (ECS Fargate):**
  - 1 ECS Cluster named `spatial-registry-cluster`
  - 1 ECS Task Definition (Fargate launch type, 512 CPU, 1024 Memory) configured to run the ECR image and expose port 8080
  - 1 ECS Service running 1 desired task, assigned to the public subnets with a public IP enabled
- **Security & IAM:**
  - 1 Security Group allowing inbound TCP on port 8080 from anywhere (0.0.0.0/0) and all outbound traffic
  - 1 ECS Task Execution IAM Role with the `AmazonECSTaskExecutionRolePolicy` managed policy attached

## 3. Required Outputs
- ECR Repository URL
- ECS Cluster Name
- ECS Service Name