# Deployment sequence

1. Bootstrap the Terraform backend in the non-production account.
2. Bootstrap the Terraform backend in the production account.
3. Enter backend outputs in each `account.hcl`.
4. Create the Terraform execution role in each account.
5. Optionally bootstrap GitHub OIDC.
6. Deploy dev.
7. Validate the application.
8. Deploy integration.
9. Validate failover and destroy behavior.
10. Deploy production through a protected GitHub environment.
