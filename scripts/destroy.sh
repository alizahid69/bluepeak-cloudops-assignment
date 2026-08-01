#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

[[ $# -ge 1 && $# -le 2 ]] || fail "Usage: ./scripts/destroy.sh <dev|int|prod> [component]"
env="$1"
component="${2:-}"
validate_environment "$env"
verify_tools

target="$(environment_path "$env")"
[[ -n "$component" ]] && target="$(component_path "$env" "$component")"
[[ -d "$target" ]] || fail "Path not found: $target"

aws sts get-caller-identity --output table

read -r -p "Type DESTROY-${env} to continue: " confirm
[[ "$confirm" == "DESTROY-${env}" ]] || fail "Cancelled."

cd "$target"
terragrunt run --all destroy
success "Destroy complete."
