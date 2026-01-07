# Application Overview

This project deploys **Umami**, an open-source web analytics platform, as a
containerized application on AWS using ECS (Fargate), Terraform, and GitHub Actions.

## Why there is no application source code here

The application itself is **not custom-written** for this project.
Instead, it uses the official Umami Docker image published by the Umami project:

- Project: https://github.com/umami-software/umami
- Docker image: `ghcr.io/umami-software/umami`

This project focuses on DevOps and infrastructure engineering**, including:
- Containerization and image management
- AWS ECS (Fargate) deployments
- Networking and security (VPC, ALB, Security Groups)
- Managed databases (Amazon RDS / Aurora PostgreSQL)
- Infrastructure as Code (Terraform)
- CI/CD automation (GitHub Actions)
- HTTPS and custom domain configuration (ACM + Route 53)

## How the application is used

The Umami container image is referenced directly in the root `Dockerfile` and
deployed as an ECS task. Configuration such as database connectivity and secrets
is provided via environment variables and AWS-managed services.

If required, the Umami source code could be cloned into this directory and
built from source using a multi-stage Dockerfile, but this is intentionally
out of scope for this project.

