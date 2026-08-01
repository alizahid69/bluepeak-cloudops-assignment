#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

find "${ROOT_DIR}" -type d \( -name ".terraform" -o -name ".terragrunt-cache" \) -prune -exec rm -rf {} +
find "${ROOT_DIR}" -type f \( -name "*.tfplan" -o -name "*.plan" -o -name "crash.log" \) -delete
success "Local Terraform and Terragrunt cache files removed."
