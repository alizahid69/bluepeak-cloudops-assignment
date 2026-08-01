#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "[ERROR] $1" >&2; exit 1; }
info() { echo "[INFO] $1"; }
success() { echo "[SUCCESS] $1"; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing command: $1"
}

verify_tools() {
  require_command terraform
  require_command terragrunt
  require_command aws
}

validate_environment() {
  case "$1" in dev|int|prod) ;; *) fail "Environment must be dev, int or prod." ;; esac
}

environment_path() {
  case "$1" in
    dev|int) echo "${ROOT_DIR}/live/nonprod/$1" ;;
    prod) echo "${ROOT_DIR}/live/prod/prod" ;;
  esac
}

component_path() {
  echo "$(environment_path "$1")/$2"
}
