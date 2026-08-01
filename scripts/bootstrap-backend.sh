#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

[[ $# -eq 2 ]] || fail "Usage: ./scripts/bootstrap-backend.sh <nonprod|prod> <aws-profile>"
account="$1"
profile="$2"
case "$account" in nonprod|prod) ;; *) fail "Account must be nonprod or prod." ;; esac

require_command terraform
require_command aws

dir="${ROOT_DIR}/bootstrap/terraform-backend"
tfvars="${dir}/${account}.tfvars"
[[ -f "$tfvars" ]] || fail "Create $tfvars from ${account}.tfvars.example first."

export AWS_PROFILE="$profile"
aws sts get-caller-identity --output table

cd "$dir"
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file="$tfvars" -out="${account}.tfplan"

read -r -p "Type BOOTSTRAP-${account} to apply: " confirm
[[ "$confirm" == "BOOTSTRAP-${account}" ]] || fail "Cancelled."

terraform apply "${account}.tfplan"
rm -f "${account}.tfplan"
terraform output
