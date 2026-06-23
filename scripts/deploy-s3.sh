#!/usr/bin/env bash
set -euo pipefail

DEFAULT_S3_BUCKET="skyskippers"
DEFAULT_CLOUDFRONT_DISTRIBUTION_ID="E1VF9CL2NFX8KT"
DEFAULT_AWS_REGION="us-east-1"
DEFAULT_DEPLOY_DIR=".."
DEFAULT_S3_PREFIX=""
EXCLUDE_PATTERNS=(
  ".git/*"
  ".gitignore"
  ".DS_Store"
  "node_modules/*"
  "package.json"
  "package-lock.json"
  "scripts/*"
  "./scripts/*"
)

S3_BUCKET="${S3_BUCKET:-${DEFAULT_S3_BUCKET}}"
CLOUDFRONT_DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:-${DEFAULT_CLOUDFRONT_DISTRIBUTION_ID}}"
AWS_REGION="${AWS_REGION:-${DEFAULT_AWS_REGION}}"
DEPLOY_DIR="${DEPLOY_DIR:-${DEFAULT_DEPLOY_DIR}}"
S3_PREFIX="${S3_PREFIX:-${DEFAULT_S3_PREFIX}}"

if ! command -v aws >/dev/null 2>&1; then
  echo "AWS CLI is required. Install and configure it before deploying." >&2
  exit 1
fi

DESTINATION="s3://${S3_BUCKET}"

if [[ -n "${S3_PREFIX}" ]]; then
  DESTINATION="${DESTINATION}/${S3_PREFIX#/}"
fi

ARGS=(
  s3 sync "${DEPLOY_DIR}" "${DESTINATION}"
  --delete
  --region "${AWS_REGION}"
)

for PATTERN in "${EXCLUDE_PATTERNS[@]}"; do
  ARGS+=(--exclude "${PATTERN}")
done

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  ARGS+=(--dryrun)
fi

echo "Deploying ${DEPLOY_DIR} to ${DESTINATION}"
aws "${ARGS[@]}"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo "Skipping CloudFront invalidation during dry run"
elif [[ -n "${CLOUDFRONT_DISTRIBUTION_ID:-}" ]]; then
  INVALIDATION_ARGS=(
    cloudfront create-invalidation
    --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}"
    --paths "/*"
    --region "${AWS_REGION}"
  )

  echo "Creating CloudFront invalidation for ${CLOUDFRONT_DISTRIBUTION_ID}"
  aws "${INVALIDATION_ARGS[@]}"
fi
