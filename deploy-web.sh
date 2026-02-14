#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BRANCH="$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"

DEV_ORG_ID="team_EmWFQ8bH8Vr73Ied2rfX5cHh"
DEV_PROJECT_ID="prj_qRCCwl8MuFf2vjXIKAhIbZMbFwx5"
PROD_ORG_ID="team_EmWFQ8bH8Vr73Ied2rfX5cHh"
PROD_PROJECT_ID="prj_xrQ91ruIG63gzMaXtFGKXaqdqy17"

cp "$PROJECT_DIR/assets/game.html" "$PROJECT_DIR/web/index.html"

cd "$PROJECT_DIR/web"

if [ "$BRANCH" = "dev" ]; then
  echo "Deploying dev branch to parity-twist-dev..."
  VERCEL_ORG_ID="$DEV_ORG_ID" VERCEL_PROJECT_ID="$DEV_PROJECT_ID" vercel --yes --prod
elif [ "$BRANCH" = "main" ]; then
  echo "Deploying main branch to parity-twist production..."
  VERCEL_ORG_ID="$PROD_ORG_ID" VERCEL_PROJECT_ID="$PROD_PROJECT_ID" vercel --yes --prod
else
  echo "ERROR: Unsupported branch '$BRANCH'. Use main or dev for production deployments."
  echo "No deployment performed."
  exit 1
fi
