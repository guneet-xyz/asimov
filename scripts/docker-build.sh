#!/bin/bash
# Build NanoClaw Docker images.
#
# Usage:
#   ./scripts/docker-build.sh              # tag as "latest"
#   ./scripts/docker-build.sh v1.2.3       # tag as "v1.2.3"
#   REGISTRY=my.registry.io/nanoclaw ./scripts/docker-build.sh
set -euo pipefail

REGISTRY="${REGISTRY:-cr.guneet.xyz/nanoclaw}"
TAG="${1:-latest}"
GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Registry:  $REGISTRY"
echo "Tag:       $TAG"
echo "Git SHA:   $GIT_SHA"
echo ""

# --- NanoClaw orchestrator ---
echo "==> Building $REGISTRY/orchestrator:$TAG ..."
docker build \
  -t "$REGISTRY/orchestrator:$TAG" \
  -t "$REGISTRY/orchestrator:$GIT_SHA" \
  "$PROJECT_ROOT"

# --- NanoClaw agent container ---
echo ""
echo "==> Building $REGISTRY/agent:$TAG ..."
docker build \
  -t "$REGISTRY/agent:$TAG" \
  -t "$REGISTRY/agent:$GIT_SHA" \
  "$PROJECT_ROOT/container"

echo ""
echo "Done. Images built:"
echo "  $REGISTRY/orchestrator:$TAG"
echo "  $REGISTRY/orchestrator:$GIT_SHA"
echo "  $REGISTRY/agent:$TAG"
echo "  $REGISTRY/agent:$GIT_SHA"
