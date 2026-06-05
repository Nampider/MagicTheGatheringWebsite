#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFRA_DIR="${INFRA_DIR:-$(cd "$APP_DIR/.." && pwd)/MagicTheGatheringInfrastructure}"
IMAGE_NAME="${IMAGE_NAME:-kriznn/magicthegatheringwebsite:latest}"
STATE_DIR="$APP_DIR/.deploy-state"
STATE_FILE="$STATE_DIR/website-image.sha256"

PUSH_IMAGE=false
NO_CACHE=false
RESET_VOLUMES=true
SEED_DATABASE=false
FORCE_BUILD=false

usage() {
    cat <<EOF
Usage: scripts/restart-website-stack.sh [options]

Builds the Spring jar, rebuilds the website Docker image when app files changed,
optionally pushes the image, and restarts the Docker Compose stack.

Options:
  --push              Push IMAGE_NAME after building. Default: false
  --no-cache          Build Docker image with --no-cache. Default: false
  --keep-volumes      Use docker compose down without -v. Default removes volumes
  --seed              Run MagicDataRetriever/databaseIntake.py after compose starts
  --force             Rebuild even if relevant files did not change
  -h, --help          Show this help

Environment:
  IMAGE_NAME          Docker image tag. Default: kriznn/magicthegatheringwebsite:latest
  INFRA_DIR           Infrastructure repo path. Default: ../MagicTheGatheringInfrastructure
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --push)
            PUSH_IMAGE=true
            ;;
        --no-cache)
            NO_CACHE=true
            ;;
        --keep-volumes)
            RESET_VOLUMES=false
            ;;
        --seed)
            SEED_DATABASE=true
            ;;
        --force)
            FORCE_BUILD=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ ! -d "$INFRA_DIR" ]]; then
    echo "Infrastructure repo not found: $INFRA_DIR"
    exit 1
fi

if [[ ! -f "$INFRA_DIR/docker-compose.yaml" ]]; then
    echo "docker-compose.yaml not found in: $INFRA_DIR"
    exit 1
fi

current_hash() {
    (
        cd "$APP_DIR"
        {
            find src -type f | sort
            find MagicDataRetriever -maxdepth 1 -type f | sort
            printf '%s\n' pom.xml Dockerfile
        } | while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                shasum -a 256 "$file"
            fi
        done
    ) | shasum -a 256 | awk '{print $1}'
}

mkdir -p "$STATE_DIR"
NEW_HASH="$(current_hash)"
OLD_HASH=""

if [[ -f "$STATE_FILE" ]]; then
    OLD_HASH="$(cat "$STATE_FILE")"
fi

if [[ "$FORCE_BUILD" == true || "$NEW_HASH" != "$OLD_HASH" ]]; then
    echo "App changes detected. Packaging and rebuilding $IMAGE_NAME..."

    (cd "$APP_DIR" && mvn -DskipTests package)

    DOCKER_BUILD_ARGS=(-t "$IMAGE_NAME")
    if [[ "$NO_CACHE" == true ]]; then
        DOCKER_BUILD_ARGS=(--no-cache "${DOCKER_BUILD_ARGS[@]}")
    fi

    (cd "$APP_DIR" && docker build "${DOCKER_BUILD_ARGS[@]}" .)

    if [[ "$PUSH_IMAGE" == true ]]; then
        docker push "$IMAGE_NAME"
    fi

    printf '%s' "$NEW_HASH" > "$STATE_FILE"
else
    echo "No app changes detected. Skipping mvn package and docker build."
fi

echo "Restarting Docker Compose stack from $INFRA_DIR..."

if [[ "$RESET_VOLUMES" == true ]]; then
    (cd "$INFRA_DIR" && docker compose down -v)
else
    (cd "$INFRA_DIR" && docker compose down)
fi

(cd "$INFRA_DIR" && docker compose up -d)

if [[ "$SEED_DATABASE" == true ]]; then
    echo "Seeding card and store inventory data..."
    (cd "$APP_DIR/MagicDataRetriever" && python3 databaseIntake.py)
fi

echo "Done. Website API should be available at http://localhost:8083"
