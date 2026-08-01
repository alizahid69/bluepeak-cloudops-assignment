# CloudOps Consulting Project

Production-style, reusable AWS three-tier platform built with Terraform and Terragrunt.

## Repository

```text
cloudops-consulting-project/
├── bootstrap/
│   ├── terraform-backend/
│   └── github-oidc/
├── modules/
│   ├── vpc/
│   ├── kms/
│   ├── security-group/
│   ├── alb/
│   ├── ec2/
│   ├── autoscaling/
│   └── rds/
├── live/
│   ├── nonprod/
│   │   ├── account.hcl
│   │   ├── dev/
│   │   └── int/
│   └── prod/
│       ├── account.hcl
│       └── prod/
├── scripts/
├── .github/workflows/
├── terragrunt.hcl
└── README.md
```

## Architecture

```text
Internet
   |
Application Load Balancer — public subnets
   |
EC2 Auto Scaling application — private subnets
   |
RDS PostgreSQL — isolated database subnets
```

- SSM Parameter Store stores configuration.
- RDS creates and manages the master database credential in Secrets Manager.
- Separate customer-managed KMS keys encrypt EBS, RDS, SSM, Secrets Manager and logs.
- EC2 uses private subnets, IMDSv2 and Session Manager; no SSH ingress is created.
- Dev and integration use the non-production AWS account.
- Production uses a separate AWS account.
- Each Terragrunt unit has an independent remote state key.

## 1. Bootstrap state

Run once in each AWS account.

```bash
cp bootstrap/terraform-backend/nonprod.tfvars.example \
   bootstrap/terraform-backend/nonprod.tfvars

./scripts/bootstrap-backend.sh nonprod my-nonprod-admin-profile
```

Repeat for production. Copy the resulting bucket and KMS ARN into:

```text
live/nonprod/account.hcl
live/prod/account.hcl
```

The backend has:

- S3 versioning
- KMS encryption
- public-access blocking
- TLS-only bucket policy
- S3 native lockfiles
- old state-version retention

Do not destroy the backend until every workload state in the account has been destroyed and backed up.

## 2. Configure accounts and environments

Update:

```text
live/nonprod/account.hcl
live/prod/account.hcl
live/nonprod/dev/environment.hcl
live/nonprod/int/environment.hcl
live/prod/prod/environment.hcl
```

## 3. Deploy locally

Authenticate to AWS, then:

```bash
./scripts/init.sh dev
./scripts/fmt.sh
./scripts/validate.sh dev
./scripts/plan.sh dev
./scripts/apply.sh dev
```

One component:

```bash
./scripts/plan.sh dev vpc
./scripts/apply.sh dev vpc
```

## 4. CI/CD

`terraform-ci.yml` performs formatting and static module validation.

`terragrunt-plan.yml` and `terragrunt-apply.yml` use GitHub Actions OIDC so no permanent AWS access keys are stored in GitHub.

Bootstrap the OIDC role from:

```text
bootstrap/github-oidc
```

Protect the GitHub `prod` environment with required reviewers before permitting production apply.

## 5. Destroy

```bash
./scripts/destroy.sh dev
```

Production RDS and ALB deletion protection must first be disabled and applied deliberately. KMS keys remain in `PendingDeletion` for the configured waiting period.

## Startup defaults

- Dev: one NAT Gateway, one EC2 instance and Single-AZ RDS.
- Integration: highly available application and RDS.
- Production: highly available application and RDS with deletion protection.
- All sizing, CIDRs, Regions and account values can be changed without modifying reusable modules.


## GitOps

This version adds EKS and Argo CD. Argo CD self-heals Kubernetes application drift; scheduled Terraform plans detect drift in AWS resources. The infrastructure workflow runs plan first and pauses at a protected GitHub environment before apply. See `docs/GITOPS.md`.


## Deployment approval workflow

EKS and Argo CD are intentionally excluded. The project continues to use the EC2 Auto Scaling three-tier architecture.

Deployment sequence:

```text
Terragrunt plan
      |
GitHub protected-environment approval
      |
Terragrunt re-plan
      |
Terragrunt apply
```

Create these GitHub environments:

```text
terraform-dev
terraform-int
terraform-prod
```

Recommended reviewer settings:

| Environment | Required reviewers |
|---|---:|
| `terraform-dev` | 0 or 1 |
| `terraform-int` | 1 |
| `terraform-prod` | 2 |

For production, restrict deployment to the `main` branch and prevent self-approval where supported.

Add these repository secrets:

```text
AWS_NONPROD_GITHUB_ROLE_ARN
AWS_PROD_GITHUB_ROLE_ARN
```

The workflow is available under:

```text
Actions → Terraform Plan and Apply
```

The apply job cannot run until the corresponding protected GitHub environment is approved.
