#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$ROOT_DIR/deploy.config"

usage() {
  cat <<'USAGE'
Usage:
  ./deploy.sh staging [--dry-run]
  ./deploy.sh production [--dry-run]

Behavior:
  staging    Syncs ./staging/ to STAGING_REMOTE_DIR
  production Syncs repo root to PROD_REMOTE_DIR, excluding staging/archive/design/.git
USAGE
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

ENVIRONMENT="$1"
DRY_RUN_FLAG=""

if [[ "${2:-}" == "--dry-run" ]]; then
  DRY_RUN_FLAG="--dry-run"
elif [[ $# -eq 2 ]]; then
  usage
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing deploy.config. Copy deploy.config.example to deploy.config and fill values."
  exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG_FILE"

if [[ -z "${SSH_TARGET:-}" ]]; then
  echo "SSH_TARGET is required in deploy.config"
  exit 1
fi

SSH_OPTS=()
if [[ -n "${SSH_PORT:-}" ]]; then
  SSH_OPTS=(-e "ssh -p $SSH_PORT")
fi

run_rsync() {
  local source_dir="$1"
  local remote_dir="$2"

  rsync -avz --delete $DRY_RUN_FLAG \
    "${SSH_OPTS[@]}" \
    "$source_dir" \
    "$SSH_TARGET:$remote_dir"
}

case "$ENVIRONMENT" in
  staging)
    if [[ ! -d "$ROOT_DIR/staging" ]]; then
      echo "Missing staging directory at $ROOT_DIR/staging"
      exit 1
    fi

    echo "Deploying staging from $ROOT_DIR/staging/ -> $SSH_TARGET:$STAGING_REMOTE_DIR"
    run_rsync "$ROOT_DIR/staging/" "${STAGING_REMOTE_DIR:?STAGING_REMOTE_DIR is required}"
    ;;

  production)
    echo "Deploying production from repo root -> $SSH_TARGET:$PROD_REMOTE_DIR"

    rsync -avz --delete $DRY_RUN_FLAG \
      "${SSH_OPTS[@]}" \
      --exclude ".git/" \
      --exclude "staging/" \
      --exclude "archive/" \
      --exclude "design/" \
      --exclude "deploy.config" \
      --exclude "deploy.config.example" \
      --exclude "deploy.sh" \
      --exclude "README.md" \
      "$ROOT_DIR/" \
      "$SSH_TARGET:${PROD_REMOTE_DIR:?PROD_REMOTE_DIR is required}"
    ;;

  *)
    usage
    exit 1
    ;;
esac

echo "Done."
