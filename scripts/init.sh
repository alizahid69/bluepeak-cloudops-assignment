#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

[[ $# -ge 1 && $# -le 2 ]] || fail "Usage: ./scripts/init.sh <dev|int|prod> [component]"
env="$1"
component="${2:-}"
validate_environment "$env"
verify_tools

target="$(environment_path "$env")"
[[ -n "$component" ]] && target="$(component_path "$env" "$component")"
[[ -d "$target" ]] || fail "Path not found: $target"

aws sts get-caller-identity --output table

cd "$target"
terragrunt run --all init --upgrade
success "Init complete."
