#!/usr/bin/env bash
set -euo pipefail
REGION=${AWS_REGION:-us-east-1}
ACCOUNT_ID=${ECR_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}
for repo in "$@"; do
  aws ecr describe-repositories --repository-names "$repo" --region "$REGION" >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name "$repo" --region "$REGION" >/dev/null
  echo "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${repo}"
done
