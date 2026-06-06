# 🛡️ AWS WAF Module (Production Grade)

![Terraform](https://img.shields.io/badge/Terraform-1.3+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-WAFv2-FF9900?logo=amazonaws)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📌 Overview

This Terraform module provisions an **AWS WAFv2 Web ACL** for protecting ALB-backed workloads with:

- IP-based rate limiting
- Regional scope (ALB compatible)
- CloudWatch metrics per rule
- Reusable across ECS, EKS, EC2, and ALB workloads

---

## 🏗️ Features

| Feature | Details |
|---------|---------|
| WAFv2 Web ACL | Regional scope, ALB attachment |
| IP Rate Limiting | Configurable request threshold |
| CloudWatch Metrics | Per-rule visibility |
| Default Action | Allow (rules block on match) |
| Reusability | Works with any ALB-backed module |

---

## 📁 Module Structure

```text
modules/WAF/
├── main.tf          # WAFv2 Web ACL, rules, metrics
├── variables.tf     # Input variable definitions
├── outputs.tf       # Exported ARN, ID, Name
└── README.md        # This file
```

---

## 🚀 Usage Example

### Standalone (module block)

```hcl
module "waf" {
  source = "../../modules/WAF"

  project_name = var.project_name
  environment  = var.environment

  enable_rate_limit = true
  rate_limit        = 2000   # max requests per 5-minute window per IP

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}
```

### Attach to ECS Module

```hcl
module "ecs" {
  source = "../../modules/ECS"

  # ... other variables ...

  enable_waf     = true
  waf_web_acl_id = module.waf.web_acl_arn
}
```

---

## 🔗 Full Root Module Integration

A typical production root module wires WAF between ACM and ECS:

```hcl
module "vpc" {
  source = "../../modules/VPC"
  # ...
}

module "acm" {
  source = "../../modules/ACM"
  # ...
}

module "waf" {
  source = "../../modules/WAF"

  project_name      = var.project_name
  environment       = var.environment
  enable_rate_limit = true
  rate_limit        = 2000
}

module "ecs" {
  source = "../../modules/ECS"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.private_subnet_ids
  alb_subnets         = module.vpc.public_subnet_ids
  security_groups     = [module.vpc.app_sg_id]
  alb_security_groups = [module.vpc.elb_sg_id]

  listener_mode   = "http_to_https"
  certificate_arn = module.acm.certificate_arn

  enable_waf     = true
  waf_web_acl_id = module.waf.web_acl_arn

  # ... services, secrets, etc.
}
```

---

## 🏛️ Architecture

```text
        ┌─────────────┐
        │  VPC Module │
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │  ACM Module │  (TLS Certificate)
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │  WAF Module │  (Web ACL — Rate Limiting, Rules)
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │  ECS Module │  (ALB + Fargate Services)
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │     ALB     │  (WAF Web ACL attached here)
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │Fargate Tasks│  (Private subnets)
        └─────────────┘
```

---

## ⚙️ Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_name` | `string` | — | Project name used in resource naming |
| `environment` | `string` | — | Environment (e.g. `dev`, `prod`) |
| `enable_rate_limit` | `bool` | `true` | Enable IP-based rate limiting rule |
| `rate_limit` | `number` | `2000` | Max requests per IP per 5-minute window |
| `tags` | `map(string)` | `{}` | Tags to apply to all resources |

---

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `web_acl_arn` | WAF Web ACL ARN — pass to ECS `waf_web_acl_id` |
| `web_acl_id` | WAF Web ACL ID |
| `web_acl_name` | WAF Web ACL Name |

---

## 🔁 Rate Limiting Behaviour

When `enable_rate_limit = true`, the WAF blocks any IP that exceeds `rate_limit` requests within a **5-minute rolling window**. The default action for all other traffic is **allow**.

```hcl
# Conservative (low traffic APIs)
rate_limit = 500

# Standard (production APIs)
rate_limit = 2000

# High traffic (public-facing apps)
rate_limit = 10000
```

---

## 📊 CloudWatch Metrics

CloudWatch metrics are enabled per rule, allowing you to monitor:

- Rate limit rule hit count
- Blocked request count
- Allowed request count

Metrics appear under the `aws-waf` namespace in CloudWatch.

---

## 🧠 Production Notes

- WAF scope is **REGIONAL** — required for ALB attachment (as opposed to `CLOUDFRONT` scope)
- The Web ACL ARN (not ID) is what gets passed to the ECS module and attached to the ALB
- WAF rules evaluate in **priority order** — rate limit rule fires before default allow
- This module is intentionally minimal and focused; managed rule groups (e.g. AWS Core, Known Bad Inputs) can be added as future extensions

---

## 🚀 Planned Extensions

- [ ] AWS Managed Rule Groups (Core, Known Bad Inputs, SQL injection)
- [ ] Geo-blocking rules
- [ ] IP allowlist / blocklist support
- [ ] WAF logging to S3 / Kinesis Firehose
- [ ] CloudFront scope support (global WAF)

---

## 👨‍💻 Author

**Muhammad Adeel** — DevOps Engineer

[![GitHub](https://img.shields.io/badge/GitHub-Portfolio-181717?logo=github)](https://github.com/)
