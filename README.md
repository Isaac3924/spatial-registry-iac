# Spatial Registry: AWS Infrastructure (IaC)

This repository contains the Terraform configuration to provision the cloud-native AWS infrastructure for the full-stack Spatial Registry application. It hosts a containerized Spring Boot backend via Amazon ECS on AWS Fargate, and a static Vue 3 frontend delivered via Amazon S3 and CloudFront.

## Architecture Overview

- **Networking:** Custom VPC (10.0.0.0/16) configured with two public subnets across distinct Availability Zones and an Internet Gateway for high availability.
- **Traffic Routing & SSL:** Application Load Balancer (ALB) integrated with AWS Certificate Manager (ACM) and Route 53. Provides a secure HTTPS endpoint with a custom domain and automatic HTTP-to-HTTPS redirection.
- **Compute:** Amazon ECS Cluster running on AWS Fargate (serverless compute), configured with 512 CPU and 1024 MiB memory.
- **Container Registry:** Amazon ECR repository for securely storing the multi-stage Spring Boot Docker image.
- **Frontend Hosting:** Amazon S3 bucket for static Vue 3 assets, distributed globally via an Amazon CloudFront CDN. Secured using Origin Access Contrl (OAC) to prevent direct bucket access, with custom error routing for SPA navigation.
- **Security & IAM:** Strict Security Groups isolating the ECS tasks to only accept traffic from the ALB. Uses an ECS Task Execution IAM Role for secure service communication.
- **CI/CD Integration (OIDC):** OpenID Connect trust relationships established between AWS and GitHub Actions. Uses dynamically verified certificates and least-privilege IAM roles mapped to exact repository IDs to enable secure, passwordless deployments for both the frontend and backend.
- **Observability:** Integrated AWS CloudWatch log groups for centralized container logging and monitoring.

## Repository Structure

- `main.tf`: Core infrastructure resources (VPC, Subnets, ALB, ECS, ECR, S3, CloudFront, ACM, Route 53, IAM, OIDC, Security Groups).
- `variables.tf`: Input variables for environment customization (Domain Name, Region, CIDR blocks, Task sizing).
- `providers.tf`: Terraform, AWS, and TLS provider version constraints.
- `INFRA_SPEC.md`: The original architecture specification used for Spec-Driven Development.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.5.0+)
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- Valid AWS IAM credentials with programmatic access (`AdministratorAccess` or equivalent for provisioning)
- [Docker](https://www.docker.com/) for building the backend image
- A custom domain name configured with an AWS Route 53 Public Hosted Zone

## Deployment Sequence

Due to the ECS service depending on the existence of the backend Docker image, the infrastructure must be deployed in a specific order:

**1. Configure Variables**
Create a `terraform.tfvars` file in the root directory and provide your domain name:
```hcl
domain_name = "your-domain.com"
```

**2. Initialize Terraform**
```bash
terraform init
```

**3. Provision the Container Registry (ECR)**
```bash
terraform apply -target=aws_ecr_repository.api
```

**4. Build and Push the Docker Image**
Authenticate Docker with your new ECR registry, build the `spatial-registry-api` Spring Boot application, and push the image to AWS.

**5. Provision the Remaining Infrastructure**
```bash
terraform apply
```
*Note: The deployment will pause for a few minutes while AWS validates the ACM SSL certificate via DNS.*

**6. Configure CI/CD Secrets**
Upon successful apply, Terraform will output several variables required for your GitHub Actions.
- **Backend Repo:** Add the `github_actions_role_arn` as a secret named `AWS_ROLE_ARN`.
- **Frontend Repo:** Add the `ui_github_actions_role_arn` as a secret named `AWS_ROLE_ARN`.
- **Frontend Repo:** Add the `api_base_url` as a secret named `VITE_API_BASE_URL`.

## Pausing & Teardown

**To pause backend compute costs without destroying infrastructure:**
Scale the Fargate tasks to zero. This keeps your network, load balancers, and ECR images intact while stopping hourly compute charges.
```bash
terraform apply -var="desired_count=0"
```

**To permanently destroy all provisioned infrastructure:**
```bash
terraform destroy
```