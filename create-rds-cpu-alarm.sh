#!/bin/bash
set -euo pipefail

AWS_REGION="eu-west-2"
DB_INSTANCE_ID="REPLACE_WITH_RDS_IDENTIFIER"
SNS_TOPIC_ARN="REPLACE_WITH_SNS_TOPIC_ARN"

aws cloudwatch put-metric-alarm \
  --region "$AWS_REGION" \
  --alarm-name "${DB_INSTANCE_ID}-cpu-over-80" \
  --alarm-description "Alarm when RDS CPUUtilization exceeds 80 percent for 5 minutes" \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value="$DB_INSTANCE_ID" \
  --statistic Average \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "$SNS_TOPIC_ARN" \
  --ok-actions "$SNS_TOPIC_ARN"
