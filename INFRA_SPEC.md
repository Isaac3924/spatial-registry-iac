# Infrastructure Spec: Spatial Registry (AWS)

## 1. Objective
Provision cloud-native AWS infrastructure using Terraform to host a containerized Spring Boot REST API and a static Vue 3 Single Page Application (SPA). The API must be securely exposed via an Application Load Balancer with a custom domain and HTTPS.

## 2. Architecture Components
- **Provider:** AWS (Region: us-east-1)
- **Networking (VPC):**
  - 1 VPC (CIDR: 10.0.0.0/16)
  - 2 Public Subnets in different Availability Zones
  - 1 Internet Gateway and corresponding route table for public access

- **Domain & DNS (Route 53 & ACM):**
  - Data source to fetch the existing Route 53 Public Hosted Zone for the custom domain.
  - AWS Certificate Manager (ACM) SSL certificate for the domain using DNS validation.
  - Route 53 DNS records to validate the ACM certificate automatically.
  - Route 53 Alias record (`api.yourdomain.com`) pointing to the Application Load Balancer.

- **Load Balancing (ALB):**
  - 1 internet-facing Application Load Balancer deployed across the public subnets.
  - 1 ALB Target Group (target type: `ip`, port 8080, protocol HTTP, with a basic `/` health check).
  - 1 HTTPS Listener (Port 443) attached to the ALB, using the validated ACM certificate and forwarding traffic to the Target Group.
  - 1 HTTP Listener (Port 80) configured to redirect all traffic to HTTPS (Port 443).

- **Container Registry:**
  - AWS ECR repository named `spatial-registry-api` to store the Docker image

- **Compute (ECS Fargate):**
  - 1 ECS Cluster named `spatial-registry-cluster`
  - 1 ECS Task Definition (Fargate launch type, 512 CPU, 1024 Memory) configured to run the ECR image and expose port 8080
  - 1 ECS Service running 1 desired task, assigned to the public subnets with a public IP enabled
  - **ALB Integration:** The ECS Service must be attached to the ALB Target Group.

- **Frontend Hosting (S3 & CloudFront):**
  - 1 S3 Bucket to host the compiled Vue 3 static assets.
  - S3 Bucket Policy configured via CloudFront Origin Access Control (OAC) to block direct public access and only allow reads from the CloudFront distribution.
  - 1 CloudFront Distribution pointing to the S3 bucket as the origin.
  - CloudFront Custom Error Responses: Redirect HTTP 403 and 404 errors to `/index.html` with a 200 HTTP status code (required for Vue Router SPA routing).

- **Security & IAM:**
  - **ALB Security Group:** Allow inbound TCP on port 443 and 80 from anywhere (0.0.0.0/0). Allow all outbound traffic.
  - **ECS Security Group:** Allow inbound TCP on port 8080 **ONLY** from the ALB Security Group (do not allow direct public access). Allow all outbound traffic.
  - 1 ECS Task Execution IAM Role with the `AmazonECSTaskExecutionRolePolicy` managed policy attached

- **CI/CD Infrastructure (GitHub Actions OIDC):**
  - Use the AWS IAM OpenID connect provider for `token.actions.githubusercontent.com` with audience `sts.amazonaws.com`.
  - **Backend Role:** Create an IAM role named `spatial-registry-github-actions-role`.
    - Restrict the `sub` claim condition to exactly `repo:Isaac3924@17149928/spatial-asset-registry@1400691459:*`.
    - Attach an IAM policy to the role allowing ECR authentication/uploading and ECS service updating (`ecs:UpdateService`) for the `spatial-registry-service`.
  - **Frontend Role:** Create an IAM role named `spatial-registry-ui-github-actions-role`.
    - Restrict the `sub` claim condition to exactly `repo:Isaac3924@17149928/spatial-registry-ui@1407917767:*`.
    - Attach an IAM policy allowing S3 object management (`s3:PutObject`, `s3:ListBucket`, `s3:DeleteObject`) on the frontend S3 bucket, and CloudFront cache invalidation (`cloudfront:CreateInvalidation`) for the distribution.

## 3. Required Outputs
- ECR Repository URL
- ECS Cluster Name
- ECS Service Name
- Backend GitHub Actions Role ARN
- CloudFront Distribution Domain Name
- Frontend GitHub Actions Role ARN
- **API Base URL:** The fully qualified HTTPS URL for the API (e.g., `https://api.yourdomain.com`)