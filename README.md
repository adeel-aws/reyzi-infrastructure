<div align="center">

# 🚀 Reyzi — Production-Grade AWS Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.3+-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS_Fargate-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![CloudFront](https://img.shields.io/badge/CloudFront-CDN-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/cloudfront/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/atlas)
[![License](https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge)](LICENSE)

**A fully automated, production-ready cloud infrastructure for a real-world full-stack application — built entirely with Terraform, deployed on AWS, following industry DevOps best practices.**

[🖥️ Frontend Repo](https://github.com/adeel-aws/reyzi-frontend) · [⚙️ Backend Repo](https://github.com/adeel-aws/reyzi-backend)

</div>

---

## 📌 Overview

This repository contains the **complete Infrastructure as Code (IaC)** for the Reyzi platform — a production-grade full-stack application. Every AWS resource is provisioned, configured, and managed through Terraform with zero manual console clicks.

The infrastructure powers a **Node.js/Express backend** on ECS Fargate and a **React (CRA) frontend** served globally through CloudFront with S3, backed by **MongoDB Atlas** — all secured with HTTPS, WAF-ready, and fully automated via GitHub Actions CI/CD pipelines.

---

## 🏗️ Architecture

```
                        ┌─────────────────────────────────────┐
                        │           GoDaddy DNS               │
                        │   www.adeeltech.bar → CloudFront    │
                        └──────────────┬──────────────────────┘
                                       │
                        ┌──────────────▼──────────────────────┐
                        │         AWS CloudFront CDN          │
                        │   ACM TLS · OAC · Security Headers  │
                        │   WAF-Ready · SPA Fallback · Geo    │
                        └──────┬───────────────────┬──────────┘
                               │                   │
              /api/* (http-only│origin)    /* (OAC)│
                               │                   │
               ┌───────────────▼───┐    ┌──────────▼──────────┐
               │  Application LB   │    │     S3 Bucket       │
               │  dual listener    │    │  (Private + OAC)    │
               │  :80 + :443       │    │  React CRA Build    │
               └───────┬───────────┘    └─────────────────────┘
                       │
          ┌────────────▼────────────────────┐
          │         AWS VPC                 │
          │  ┌──────────────────────────┐   │
          │  │   ECS Fargate (Private)  │   │
          │  │   Node.js / Express      │   │
          │  │   port 5000              │   │
          │  │   CloudWatch Logs        │   │
          │  │   Autoscaling (CPU/Mem)  │   │
          │  └──────────────────────────┘   │
          │  Private Subnets · NAT Gateway  │
          └──────────────┬──────────────────┘
                         │
          ┌──────────────▼──────────────────┐
          │        AWS Secrets Manager       │
          │        MongoDB Atlas URI         │
          └──────────────┬──────────────────┘
                         │
          ┌──────────────▼──────────────────┐
          │       MongoDB Atlas M0           │
          │    AWS us-east-1 · Free Tier     │
          └─────────────────────────────────┘
```

---

## ✨ Key Features

### Infrastructure
- **Modular Terraform Architecture** — Every AWS service is an independent, reusable module (`VPC`, `ECS`, `CloudFront`, `S3`, `ACM`, `ECR`, `Secrets Manager`)
- **Zero-Downtime Deployments** — ECS rolling updates with circuit breaker and automatic rollback
- **Dual ALB Listener Mode** — HTTP `:80` forward + HTTPS `:443` forward — engineered specifically to eliminate CloudFront → ALB redirect loops
- **CloudFront OAC** — S3 bucket is fully private; only CloudFront can read objects via Origin Access Control (the modern successor to OAI)
- **Remote State Management** — Terraform state stored in S3 with DynamoDB state locking — no concurrent apply conflicts
- **Staged Apply Strategy** — ACM certificate provisioned first, DNS-validated via GoDaddy CNAMEs, then full infrastructure apply

### Security
- **Zero Secrets in Code** — MongoDB URI injected via AWS Secrets Manager at ECS task runtime; never in tfvars, never in environment files
- **Private Subnets** — ECS Fargate tasks have no public IPs; all traffic routed through NAT Gateway
- **ACM TLS** — Wildcard-ready certificate covering `adeeltech.bar` + `www.adeeltech.bar` (SAN)
- **Security Headers** — CloudFront response headers policy enforces HSTS, X-Frame-Options, XSS protection, referrer policy
- **IAM Least Privilege** — Separate execution role (image pull + secrets) and task role (app-level AWS calls) with scoped policies

### Observability
- **CloudWatch Log Groups** — Per-service log groups with configurable retention
- **Container Insights** — ECS cluster-level metrics enabled
- **ALB Health Checks** — Strict `200`-only health check matcher on `/health` endpoint

### Cost Optimisation
- **S3 Lifecycle Rules** — Automatic transition to `STANDARD_IA` at 30 days, expiration at 60 days
- **ECS Fargate** — Serverless containers; pay only for running tasks
- **CloudFront `PriceClass_100`** — North America + Europe edge locations only

---

## 📁 Repository Structure

```
reyzi-infrastructure/
│
├── root
│   └── 
|       ├── screenshots          # Infra & application screenshots
│       ├── main.tf              # Core modules: DynamoDB, S3 state, ACM, VPC, Secrets, ECR, ECS
│       ├── frontend.tf          # S3 frontend bucket + CloudFront distribution
│       ├── variables.tf         # All input variable declarations
│       ├── outputs.tf           # Key outputs: ALB DNS, CF domain, ECR URL, cluster name
│       ├── backend.tf           # Remote state backend (S3 + DynamoDB)
│       ├── terraform.tfvars     # Variables actual Values 
│       └── README.md            # Here you are currently
|
└── modules/
    ├── ACM/                     # TLS certificate + DNS validation records
    ├── CloudFront/              # CDN distribution, OAC, behaviors, security headers
    ├── ECR/                     # Private container registry
    ├── ECS/                     # Fargate cluster, ALB, listeners, target groups, autoscaling
    ├── S3/                      # Bucket with mode-based access (private/public/cloudfront)
    ├── Secrets-Manager/         # Secret creation + IAM policy generation
    ├── VPC/                     # Subnets, NAT gateway, security groups, route tables
    └── WAF/                     # WAFv2 Web ACL (rate limiting, regional scope)
```

---

## 🔧 Modules Deep Dive

### ECS Module
The most complex module — supports four **listener modes** via a single `listener_mode` variable:

| Mode | `:80` | `:443` | Use Case |
|------|-------|--------|----------|
| `http_only` | forward | — | Internal / dev |
| `https_only` | — | forward | Direct HTTPS only |
| `http_to_https` | redirect | forward | Standard production |
| `dual` | forward | forward | **Behind CloudFront** ✓ |

`dual` mode is the key architectural decision — CloudFront hits the ALB over HTTP (AWS internal network), while browsers access via HTTPS through CloudFront. This eliminates the 502/redirect-loop issue that plagues most CloudFront + ALB setups.

### CloudFront Module
- Two origin types: `s3` (with OAC auto-wiring) and `custom` (ALB)
- `origin_protocol_policy = "http-only"` for ALB origin — avoids SSL mismatch on `*.elb.amazonaws.com`
- Path-based routing: `/api/*` → ALB, `/*` → S3
- SPA fallback: 403/404 → `index.html` for React Router

### S3 Module
Three access modes with `access_mode` variable:

| Mode | Public Access Block | Bucket Policy |
|------|--------------------|--------------  |
| `private` | all ON | none |
| `public` | all OFF | open GetObject |
| `cloudfront` | all ON | OAC `AWS:SourceArn` condition |

### Secrets Manager Module
Stores MongoDB URI as a plain string. ECS task definition injects it as `MONGO_URI` environment variable at runtime. The execution role is automatically granted `secretsmanager:GetSecretValue` via a scoped IAM policy.

---

## 🚀 Multi-Repo Architecture

This project follows a **polyrepo** pattern — three separate GitHub repositories with distinct responsibilities:

```
┌─────────────────────────────────────────────────────────────┐
│                     Reyzi Platform                           │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────┐  │
│  │ reyzi-frontend  │  │  reyzi-backend  │  │ reyzi-app- │  │
│  │                 │  │                 │  │infrastructure│ │
│  │  React CRA      │  │  Node.js        │  │            │  │
│  │  Redux          │  │  Express        │  │  Terraform  │  │
│  │  Socket.IO      │  │  Mongoose       │  │  Modules   │  │
│  │  Axios          │  │  Socket.IO      │  │  IaC       │  │
│  │                 │  │  Agenda         │  │            │  │
│  │  → S3 + CF      │  │  → ECS Fargate  │  │  → AWS     │  │
│  └────────┬────────┘  └────────┬────────┘  └────────────┘  │
│           │                    │                             │
│    GitHub Actions        GitHub Actions                      │
│    on push to main       on push to main                     │
└─────────────────────────────────────────────────────────────┘
```

**Why polyrepo?**
- Independent deployment cycles — backend can deploy without touching frontend
- Separate access controls per repo
- Clean separation of concerns — infra changes never trigger app CI
- Recruiters can inspect each layer independently

---

## ⚙️ CI/CD Pipelines

### Backend Pipeline (`reyzi-backend`)
```
push to main
    │
    ├── Configure AWS credentials
    ├── Login to Amazon ECR
    ├── docker build → tag :latest
    ├── docker push → ECR
    ├── aws ecs update-service --force-new-deployment
    └── aws ecs wait services-stable
```

### Frontend Pipeline (`reyzi-frontend`)
```
push to main
    │
    ├── Setup Node.js 18
    ├── npm ci
    ├── Clear node_modules/.cache
    ├── npm run build (CI=false, inject secrets)
    ├── aws s3 sync build/ → S3
    │       ├── static assets: cache-control max-age=31536000
    │       └── index.html:   cache-control no-cache
    └── CloudFront invalidation /*
```

All secrets (AWS credentials, ECR URL, CloudFront ID, API URL) are stored as **GitHub Secrets** — never in code.

---

## 📸 Screenshots

<table>
  <tr>
   <td align="center" colspan="2">
    <img src="screenshots/login.png" width="800" alt="Login Page"/>
    <br /><strong>Login Page</strong>
   </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/dashboard.png" width="400" alt="Application Dashboard"/>
      <br /><strong>Application Dashboard</strong>
    </td>
    <td align="center">
      <img src="screenshots/cloudfront.png" width="400" alt="CloudFront Distribution"/>
      <br /><strong>CloudFront Distribution</strong>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/cluster.png" width="400" alt="ECS Cluster"/>
      <br /><strong>ECS Cluster</strong>
    </td>
    <td align="center">
      <img src="screenshots/service.png" width="400" alt="ECS Service Health"/>
      <br /><strong>ECS Service — Running & Healthy</strong>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/cicd-backend.png" width="400" alt="Backend CI/CD Pipeline"/>
      <br /><strong>Backend CI/CD — GitHub Actions</strong>
    </td>
    <td align="center">
      <img src="screenshots/cicd-frontend.png" width="400" alt="Frontend CI/CD Pipeline"/>
      <br /><strong>Frontend CI/CD — GitHub Actions</strong>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/loadbalancer.png" width="400" alt="Application Load Balancer"/>
      <br /><strong>ALB — Dual Listener Mode</strong>
    </td>
    <td align="center">
      <img src="screenshots/logs.png" width="400" alt="Container Logs"/>
      <br /><strong>Container Logs</strong>
    </td>
  </tr>
</table>

> 📁 Screenshots are stored in the `/screenshots` directory at the repo root.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| IaC | Terraform 1.3+ |
| Cloud | AWS (us-east-1) |
| Compute | ECS Fargate |
| CDN | CloudFront |
| Storage | S3 |
| Registry | ECR |
| Load Balancer | ALB (Application) |
| TLS | ACM (DNS validated) |
| Secrets | AWS Secrets Manager |
| Database | MongoDB Atlas (M0, AWS us-east-1) |
| State Backend | S3 + DynamoDB |
| DNS | GoDaddy |
| CI/CD | GitHub Actions |
| Frontend | React CRA, Redux, Socket.IO |
| Backend | Node.js, Express, Mongoose |

---

## 🚦 Getting Started

### Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.3
- MongoDB Atlas cluster with a database user
- GoDaddy domain

### Apply Order

```bash
# 1. Clone the repo
git clone https://github.com/muhammadadeel147/reyzi-app-infrastructure
cd reyzi-app-infrastructure/environments/dev

# 2. Copy and fill in your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — DO NOT commit this file

# 3. Set MongoDB URI as environment variable (never in tfvars)
export TF_VAR_mongo_uri="mongodb+srv://user:pass@cluster.mongodb.net/dbname"
export TF_VAR_jwt_secret="your-jwt-secret"

# 4. Init Terraform
terraform init

# 5. Apply ACM first — get DNS validation CNAMEs
terraform apply -target=module.acm

# 6. Add the CNAME records to GoDaddy
#    Wait for certificate status = ISSUED in AWS Console

# 7. Apply everything
terraform apply

# 8. Note the outputs
terraform output
```

### Required GitHub Secrets

**Backend repo (`reyzi-backend`):**

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `ECR_REPOSITORY_URL` | From `terraform output ecr_repository_url` |
| `ECS_CLUSTER_NAME` | From `terraform output ecs_cluster_name` |
| `ECS_SERVICE_NAME` | From `terraform output ecs_service_names` |

**Frontend repo (`reyzi-frontend`):**

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `S3_BUCKET_NAME` | Frontend bucket name |
| `CLOUDFRONT_DISTRIBUTION_ID` | From `terraform output cloudfront_distribution_id` |
| `REACT_APP_API_URL` | `https://www.adeeltech.bar/api` |
| `REACT_APP_PROJECT_NAME` | `Reyzi` |

---

## 📤 Terraform Outputs

After `terraform apply`, key outputs include:

| Output | Description |
|--------|-------------|
| `alb_dns` | ALB DNS name |
| `cloudfront_domain` | Raw CloudFront domain |
| `cloudfront_distribution_id` | For GitHub Actions invalidation |
| `ecr_repository_url` | For Docker push in CI |
| `ecs_cluster_name` | For ECS deploy commands |
| `ecs_service_names` | Map of service names |
| `acm_certificate_arn` | Certificate ARN |
| `acm_validation_records` | CNAMEs for GoDaddy |

---

## 🔐 Security Notes

- MongoDB URI is **never** stored in tfvars — always passed via `TF_VAR_mongo_uri`
- JWT secret is **never** in code — passed via `TF_VAR_jwt_secret`
- ECS tasks run in **private subnets** with no public IPs
- S3 bucket has **all public access blocked** — accessible only via CloudFront OAC

---

## 🚀 Planned Extensions

- [ ] Blue/Green deployments via AWS CodeDeploy
- [ ] WAF managed rule groups (Core, SQL injection, Known Bad Inputs)
- [ ] Multi-environment support (`staging`, `prod`) with workspace isolation
- [ ] Route53 for automated DNS validation (eliminate manual GoDaddy step)
- [ ] AWS Config + CloudTrail for compliance and audit logging
- [ ] Canary deployments with traffic shifting

---

## 👨‍💻 Author

**Muhammad Adeel** — DevOps Engineer

[![GitHub](https://img.shields.io/badge/GitHub-muhammadadeel147-181717?style=for-the-badge&logo=github)](https://github.com/adeel-aws)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/adeel-aws)

---

<div align="center">

**⭐ If this project helped you, consider giving it a star!**

*Built with ❤️ and a lot of `terraform apply`*

</div>