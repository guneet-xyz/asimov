#!/bin/bash
# Push NanoClaw Docker images to the container registry.
# Run docker-build.sh first.
#
# Usage:
#   ./scripts/docker-push.sh              # push "latest"
#   ./scripts/docker-push.sh v1.2.3       # push "v1.2.3"
#   REGISTRY=my.registry.io/nanoclaw ./scripts/docker-push.sh
set -euo pipefail

REGISTRY="${REGISTRY:-cr.guneet.xyz/nanoclaw}"
TAG="${1:-latest}"
GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")"

echo "Registry:  $REGISTRY"
echo "Tag:       $TAG"
echo "Git SHA:   $GIT_SHA"
echo ""

echo "==> Pushing $REGISTRY/orchestrator ..."
docker push "$REGISTRY/orchestrator:$TAG"
docker push "$REGISTRY/orchestrator:$GIT_SHA"

echo ""
echo "==> Pushing $REGISTRY/agent ..."
docker push "$REGISTRY/agent:$TAG"
docker push "$REGISTRY/agent:$GIT_SHA"

echo ""
echo "Done. Images pushed:"
echo "  $REGISTRY/orchestrator:$TAG"
echo "  $REGISTRY/orchestrator:$GIT_SHA"
echo "  $REGISTRY/agent:$TAG"
echo "  $REGISTRY/agent:$GIT_SHA"
