#!/usr/bin/env bash
set -euo pipefail
REGION=${AWS_REGION:-us-east-1}
CLUSTER_NAME=${CLUSTER_NAME:-micro-eks}
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"
