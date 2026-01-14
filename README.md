# ECS Umami Deployment (Terraform + GitHub Actions + OIDC)

This project demonstrates a production-style deployment of a containerized web application to AWS using:
- **Docker** (container build)
- **Amazon ECS Fargate** (serverless containers)
- **Application Load Balancer** (traffic routing + health endpoint)
- **RDS Postgres** (managed database)
- **ACM + Route 53** (HTTPS + custom domain)
- **Terraform modules** (infrastructure as code)
- **GitHub Actions + OIDC** (CI/CD with no static AWS keys)

Live URL: `https://tm.mhecsproject.com`  
Health endpoint (ALB-level): `https://tm.mhecsproject.com/health`

*Deployed App*

---

<p align="center">
  <img src="images/Umami-UI.png" style="width:700px"/>
</p>


---

## Architecture

---

<p align="center">
  <img src="images/Flowcharts.png" style="width:700px"/>
</p>
---

**Key design decisions**

- HTTPS enforced: HTTP (80) redirects to HTTPS (443).

- Stable /health: Implemented as an ALB listener rule fixed-response, so CI/CD health checks do not depend on application routes.

- OIDC for CI/CD: GitHub Actions assumes an AWS IAM Role using OIDC → no long-lived credentials stored in GitHub.

- Terraform modules: Networking, security groups, ALB, ECS, RDS, DNS/ACM separated for clarity and reuse.

**Repo Structure**  
```

.
├─ .github/
│  └─ workflows/
│     ├─ test-build.yml            # Build & push Docker image to ECR (CI)
│     ├─ plan.yml                  # Terraform plan (CI – no changes applied)
│     ├─ apply.yml                 # Terraform apply (manual, OIDC-secured)
│     └─ destroy.yml               # Terraform destroy (manual cleanup)
│
├─ bootstrap/
│  ├─ main.tf                      # S3 backend + DynamoDB lock table
│  ├─ variables.tf                 # Bootstrap variables
│  └─ outputs.tf                  # Backend outputs
│
├─ infra/
│  ├─ main.tf                      # Wires all Terraform modules together
│  ├─ variables.tf                 # Root module input variables
│  ├─ outputs.tf                   # Key outputs (app_url, alb_dns_name, ecr_url)
│  ├─ backend.tf                   # Remote state configuration (S3 + DynamoDB)
│  ├─ terraform.tfvars.example     # Example non-secret values
│  └─ modules/
│     ├─ vpc/                      # Custom VPC (subnets, routes, IGW)
│     ├─ security/                 # Security groups
│     ├─ alb/                      # Application Load Balancer + listeners
│     ├─ ecs/                      # ECS cluster, service, task definition
│     ├─ ecr/                      # ECR repository
│     ├─ rds/                      # RDS PostgreSQL
│     └─ dns_acm/                  # Route 53 + ACM certificate validation
│
├─ Dockerfile                      # Application container definition
├─ .dockerignore                   # Docker build exclusions
├─ README.md                       # Project documentation
└─ .gitignore                      # Git ignore rules (Terraform, Docker, local files)

```
---

## CI/CD
1) **Build & Push (Docker → ECR)**

- Triggered on push to main (and manual workflow_dispatch):

- Builds image

- Tags with commit SHA

- Pushes to ECR

2) **Deploy (Terraform)**

Triggered on push to main (and manual workflow_dispatch):

- terraform init

- terraform fmt/validate

- terraform plan (non-interactive)

- terraform apply

- Post-deploy verification:

curl -fsS https://tm.mhecsproject.com/health | grep "ok"

3) **Terraform Destroy**

- Removes all Terraform-managed AWS resources when not in use, securely and safely producing a clean environment

**Requirements / Setup**

*AWS*

- Domain hosted in Route 53

- ACM certificate validated for tm.mhecsproject.com in the ALB region

*GitHub Secrets*

Set these repository secrets:

- AWS_REGION (e.g. eu-north-1)

- AWS_ROLE_ARN (OIDC role for GitHub Actions)

- TF_VAR_APP_SECRET (32+ random chars)

- TF_VAR_DB_PASSWORD

- TF_VAR_ACM_CERTIFICATE_ARN

Non-secret values can be committed via infra/terraform.auto.tfvars (optional).

**Run the app (Local)**

*Prerequisites*
- Docker
- Node.js (optional, if running without Docker)

*Build and Run*

```

docker build -t umami-local .
docker run -p 3000:3000 \
  -e DATABASE_URL=postgres://user:pass@localhost:5432/db \
  -e APP_SECRET=dev-secret \
  umami-local

```

Verify:

```

curl http://localhost:3000

```
**Run Terraform Locally**

```

terraform -chdir=infra init
terraform -chdir=infra plan
terraform -chdir=infra apply
terraform -chdir=infra destroy
```
Verify:
```

curl -I http://tm.mhecsproject.com/         # should 301 -> https
curl -i --http2 https://tm.mhecsproject.com/health  # should 200 {"status":"ok"}
```

# Domain Page:

<p align="center">
  <img src="images/Umami UI.png
  " style="width:700px"/>
</p>

# Docker Build and Push:

<p align="center">
  <img src="images/Build-and-push.png" style="width:700px"/>
</p>

# Terraform Plan

<p align="center">
  <img src="images/TerraformPlan.png" style="width:700px"/>
</p>

# Terraform Apply

<p align="center">
  <img src="images/TerraformApply.png" style="width:700px"/>
</p>

# Terraform Destroy:

<p align="center">
  <img src="images/TerraformDestroy.png" style="width:700px"/>
</p>

**Troubleshooting Notes**

- 503 from ALB usually means target group has no healthy targets (task crashed / wrong port / SG blocked).

- TLS errors connecting to DB were resolved by setting sslmode=no-verify for RDS connectivity (Umami/Prisma TLS chain behavior).

- State lock errors (bonus backend): DynamoDB lock prevents concurrent terraform runs. Use terraform force-unlock <LOCK_ID> only when you’re sure no apply is running.

