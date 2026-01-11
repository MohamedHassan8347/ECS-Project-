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
  U[User Browser] -->|HTTPS 443| ALB[Application Load Balancer]
  ALB -->|Forward /| ECS[ECS Fargate Service (Umami container)]
  ECS -->|SQL (5432)| RDS[(RDS Postgres)]

  ALB -->|Fixed response /health| H[{"status":"ok"}]
  DNS[Route 53: tm.mhecsproject.com] --> ALB
  ACM[ACM Certificate] --> ALB
