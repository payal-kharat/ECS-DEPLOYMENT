#!/usr/bin/env bash

set -euo pipefail

# ---------------------------------------------------------
# Arguments
# ---------------------------------------------------------

CLUSTER="$1"
SERVICE="$2"
IMAGE="$3"
CONTAINER_NAME="$4"

REGION="${AWS_REGION:-us-east-1}"

echo "=============================================="
echo "ECS Deployment"
echo "=============================================="
echo "Cluster        : $CLUSTER"
echo "Service        : $SERVICE"
echo "Container      : $CONTAINER_NAME"
echo "Image          : $IMAGE"
echo "Region         : $REGION"
echo "=============================================="

# ---------------------------------------------------------
# Step 1: Get current task definition
# ---------------------------------------------------------

echo "Getting current ECS task definition..."

CURRENT_TASK_DEF=$(aws ecs describe-services \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --region "$REGION" \
    --query 'services[0].taskDefinition' \
    --output text)

echo "Current Task Definition:"
echo "$CURRENT_TASK_DEF"

# ---------------------------------------------------------
# Step 2: Download current task definition JSON
# ---------------------------------------------------------

echo "Downloading current task definition..."

aws ecs describe-task-definition \
    --task-definition "$CURRENT_TASK_DEF" \
    --region "$REGION" \
    --query 'taskDefinition' \
    --output json > /tmp/current-task-definition.json

# ---------------------------------------------------------
# Step 3: Update container image
# ---------------------------------------------------------

echo "Updating container image..."

python3 - "$IMAGE" "$CONTAINER_NAME" \
    /tmp/current-task-definition.json \
    /tmp/new-task-definition.json <<'PY'

import json
import sys

image = sys.argv[1]
container_name = sys.argv[2]
source_file = sys.argv[3]
destination_file = sys.argv[4]

# Read existing task definition
with open(source_file) as f:
    task_definition = json.load(f)

# Find required container
container_found = False

for container in task_definition["containerDefinitions"]:

    if container.get("name") == container_name:

        container["image"] = image
        container_found = True

        print(
            f"Updated container '{container_name}' "
            f"with image '{image}'"
        )

        break

# Stop if container does not exist
if not container_found:
    raise SystemExit(
        f"ERROR: Container '{container_name}' "
        f"not found in task definition"
    )

# ---------------------------------------------------------
# Remove AWS generated fields
# ---------------------------------------------------------

allowed_fields = [
    "family",
    "taskRoleArn",
    "executionRoleArn",
    "networkMode",
    "containerDefinitions",
    "volumes",
    "placementConstraints",
    "requiresCompatibilities",
    "cpu",
    "memory",
    "pidMode",
    "ipcMode",
    "proxyConfiguration",
    "inferenceAccelerators",
    "ephemeralStorage",
    "runtimePlatform"
]

new_task_definition = {
    key: task_definition[key]
    for key in allowed_fields
    if key in task_definition
}

# Save new task definition
with open(destination_file, "w") as f:
    json.dump(new_task_definition, f, indent=2)

print("New task definition JSON created.")

PY

# ---------------------------------------------------------
# Step 4: Register new ECS task definition
# ---------------------------------------------------------

echo "Registering new ECS task definition..."

NEW_TASK_DEF=$(aws ecs register-task-definition \
    --cli-input-json file:///tmp/new-task-definition.json \
    --region "$REGION" \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text)

echo "New Task Definition:"
echo "$NEW_TASK_DEF"

# ---------------------------------------------------------
# Step 5: Update ECS service
# ---------------------------------------------------------

echo "Updating ECS service..."

aws ecs update-service \
    --cluster "$CLUSTER" \
    --service "$SERVICE" \
    --task-definition "$NEW_TASK_DEF" \
    --force-new-deployment \
    --region "$REGION"

# ---------------------------------------------------------
# Step 6: Wait for deployment
# ---------------------------------------------------------

echo "Waiting for ECS service to become stable..."

aws ecs wait services-stable \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --region "$REGION"

echo "=============================================="
echo "ECS DEPLOYMENT SUCCESSFUL"
echo "=============================================="
echo "Cluster   : $CLUSTER"
echo "Service   : $SERVICE"
echo "Container : $CONTAINER_NAME"
echo "Image     : $IMAGE"
echo "Task Def  : $NEW_TASK_DEF"
echo "=============================================="
