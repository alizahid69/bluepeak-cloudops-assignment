#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

require_command terraform
require_command terragrunt

terraform fmt -recursive "${ROOT_DIR}/modules"
terragrunt hcl fmt --working-dir "${ROOT_DIR}/live"
terragrunt hcl fmt --working-dir "${ROOT_DIR}"
success "Formatting complete."
