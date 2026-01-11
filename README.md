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

---

## Architecture

```mermaid
flowchart LR
  U[User Browser]
  R53[Route 53]
  ALB[Application Load Balancer]
  ECS["ECS Fargate Service - Umami"]
  RDS[(PostgreSQL RDS)]
  CW[CloudWatch Logs]
  ECR[Amazon ECR]
  GH[GitHub Actions]
  ACM[ACM Certificate]

  U -->|DNS lookup| R53
  R53 --> ALB

  U -->|HTTP :80| ALB
  ALB -->|301 Redirect| U

  U -->|HTTPS :443| ALB
  ACM --> ALB

  ALB -->|/health| FIXED["ALB Fixed Response 200"]
  ALB -->|/| ECS

  ECS --> RDS
  ECS --> CW

  GH -->|Build & Push| ECR
  GH -->|Terraform Apply| ALB

