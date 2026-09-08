#!/bin/bash
set -euo pipefail

CLUSTER_NAME="${1:?Usage: bootstrap-cloudwatch-agent.sh <cluster-name> <aws-region>}"
REGION="${2:?Usage: bootstrap-cloudwatch-agent.sh <cluster-name> <aws-region>}"

MANIFEST_URL="https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml"

curl -sS "$MANIFEST_URL" \
  | sed "s/{{cluster_name}}/${CLUSTER_NAME}/g; s/{{region_name}}/${REGION}/g" \
  | kubectl apply -f -

echo "Applied. Verify with: kubectl get pods -n amazon-cloudwatch"
