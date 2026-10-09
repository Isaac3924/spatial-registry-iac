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
- **CI/CD Infrastructure (GitHub Actions OIDC):**
  - Create an AWS IAM OpenID connect provider for `token.actions.githubusercontent.com` with audience `sts.amazonaws.com`.
  - Create an IAM role named `spatial-registry-github-actions-role` that assumes web identity via the OIDC provider.
  - Restrict the `sub` claim condition to exactly `repo:Isaac3924/spatial-registry:*`.
  - Attach an IAM policy to the role allowing ECR authentication/uploading (batch check, initiate layer upload, put image, etc.) and ECS service updating (`ecs:UpdateService`) for the `spatial-registry-service`.

## 3. Required Outputs
- ECR Repository URL
- ECS Cluster Name
- ECS Service Name
- GitHub Actions Role ARN