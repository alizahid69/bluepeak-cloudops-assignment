# Terraform approval workflow

## Pull-request stage

Pull requests run formatting and static Terraform validation. They do not apply infrastructure.

## Deployment stage

The manually triggered workflow runs:

1. AWS authentication through GitHub OIDC.
2. Terraform and Terragrunt formatting checks.
3. Terragrunt plan.
4. GitHub protected-environment approval.
5. A second Terragrunt plan.
6. Terragrunt apply.

## GitHub environments

Create:

- `terraform-dev`
- `terraform-int`
- `terraform-prod`

Recommended approval policy:

- Development: optional or one reviewer.
- Integration: one reviewer.
- Production: two reviewers and main-branch restriction.

## Why re-plan after approval?

Infrastructure or state could change while approval is pending. Re-planning ensures the apply job uses the current infrastructure view instead of relying on an outdated plan.
