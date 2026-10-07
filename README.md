# Spatial Registry: AWS Infrastructure (IaC)

This repository contains the Terraform configuration to provision the cloud-native AWS infrastructure for the Spatial Registry backend. The architecture leverages Amazon ECS on AWS Fargate for serverless container orchestration, demonstrating modern Infrastructure-as-Code (IaC) principles.

## Architecture Overview

- **Networking:** Custom VPC (10.0.0.0/16) configured with two public subnets across distinct Availability Zones and an Internet Gateway for high availability.
- **Compute:** Amazon ECS Cluster running on AWS Fargate (serverless compute), configured with 512 CPU and 1024 MiB memory.
- **Container Registry:** Amazon ECR repository for securely storing the multi-stage Spring Boot Docker image.
- **Security & IAM:** Dedicated Security Group exposing port 8080, combined with an ECS Task Execution IAM Role for secure service communication.
- **Observability:** Integrated AWS CloudWatch log groups for centralized container logging and monitoring.

## Repository Structure

- `main.tf`: Core infrastructure resources (VPC, Subnets, ECS, ECR, IAM, Security Groups).
- `variables.tf`: Input variables for environment customization (Region, CIDR blocks, Task sizing).
- `providers.tf`: Terraform and AWS provider version constraints.
- `INFRA_SPEC.md`: The original architecture specification used for Spec-Driven Development.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.5.0+)
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- Valid AWS IAM credentials with programmatic access (`AdministratorAccess` or equivalent for provisioning)
- [Docker](https://www.docker.com/) for building the backend image

## Deployment Sequence

Due to the ECS service depending on the existence of the backend Docker image, the infrastructure must be deployed in a specific order:

**1. Initialize Terraform**
```bash
terraform init
```

**2. Provision the Container Registry (ECR)**
```bash
terraform apply -target=aws_ecr_repository.api
```

**3. Build and Push the Docker Image**
Authenticate Docker with your new ECR registry, build the `spatial-registry-api` Spring Boot application, and push the image to AWS.

**4. Provision the Remaining Infrastructure**
```bash
terraform apply
```

## Teardown

To avoid ongoing AWS charges, destroy all provisioned infrastructure when testing is complete:
```bash
terraform destroy
```