#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "$APP_DIR/.." && pwd)"
INFRA_DIR="${INFRA_DIR:-$(cd "$APP_DIR/.." && pwd)/MagicTheGatheringInfrastructure}"
COMMERCE_DIR="${COMMERCE_DIR:-$ROOT_DIR/MagicTheGatheringCommerce}"
WEBSITE_IMAGE_NAME="${WEBSITE_IMAGE_NAME:-${IMAGE_NAME:-kriznn/magicthegatheringwebsite:latest}}"
COMMERCE_IMAGE_NAME="${COMMERCE_IMAGE_NAME:-kriznn/magicthegatheringcommerce:latest}"
STATE_DIR="$APP_DIR/.deploy-state"

PUSH_IMAGE=false
NO_CACHE=false
RESET_VOLUMES=true
SEED_DATABASE=false
FORCE_BUILD=false

usage() {
    cat <<EOF
Usage: scripts/restart-website-stack.sh [options]

Builds the Spring jars, rebuilds the website and commerce Docker images when app files changed,
optionally pushes the images, and restarts the Docker Compose stack.

Options:
  --push              Push IMAGE_NAME after building. Default: false
  --no-cache          Build Docker image with --no-cache. Default: false
  --keep-volumes      Use docker compose down without -v. Default removes volumes
  --seed              Run MagicDataRetriever/databaseIntake.py after compose starts
  --force             Rebuild even if relevant files did not change
  -h, --help          Show this help

Environment:
  WEBSITE_IMAGE_NAME  Website Docker image tag. Default: kriznn/magicthegatheringwebsite:latest
  IMAGE_NAME          Backwards-compatible alias for WEBSITE_IMAGE_NAME
  COMMERCE_IMAGE_NAME Commerce Docker image tag. Default: kriznn/magicthegatheringcommerce:latest
  COMMERCE_DIR        Commerce repo path. Default: ../MagicTheGatheringCommerce
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

if [[ ! -d "$COMMERCE_DIR" ]]; then
    echo "Commerce repo not found: $COMMERCE_DIR"
    exit 1
fi

if [[ ! -f "$COMMERCE_DIR/pom.xml" || ! -f "$COMMERCE_DIR/Dockerfile" ]]; then
    echo "Commerce repo must contain pom.xml and Dockerfile: $COMMERCE_DIR"
    exit 1
fi

checksum_file() {
    local file="$1"

    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file"
        return
    fi

    sha256sum "$file"
}

checksum_stdin() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256
        return
    fi

    sha256sum
}

repo_hash() {
    local repo_dir="$1"

    (
        cd "$repo_dir"
        {
            find src -type f 2>/dev/null | sort
            if [[ -d MagicDataRetriever ]]; then
                find MagicDataRetriever -maxdepth 1 -type f | sort
            fi
            printf '%s\n' pom.xml Dockerfile
        } | while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                checksum_file "$file"
            fi
        done
    ) | checksum_stdin | awk '{print $1}'
}

package_repo() {
    local repo_dir="$1"

    if [[ -x "$repo_dir/mvnw" && -f "$repo_dir/.mvn/wrapper/maven-wrapper.properties" ]]; then
        (cd "$repo_dir" && ./mvnw -DskipTests clean package)
        return
    fi

    if [[ -f "$repo_dir/mvnw.cmd" && -f "$repo_dir/.mvn/wrapper/maven-wrapper.properties" ]]; then
        (cd "$repo_dir" && ./mvnw.cmd -DskipTests clean package)
        return
    fi

    if ! command -v mvn >/dev/null 2>&1; then
        echo "No complete Maven wrapper found in $repo_dir, and global mvn is not on PATH."
        echo "Expected wrapper metadata at: $repo_dir/.mvn/wrapper/maven-wrapper.properties"
        exit 1
    fi

    (cd "$repo_dir" && mvn -DskipTests clean package)
}

build_service_if_changed() {
    local service_name="$1"
    local repo_dir="$2"
    local image_name="$3"
    local state_file="$STATE_DIR/$service_name-image.sha256"
    local new_hash
    local old_hash=""

    new_hash="$(repo_hash "$repo_dir")"

    if [[ -f "$state_file" ]]; then
        old_hash="$(cat "$state_file")"
    fi

    if [[ "$FORCE_BUILD" == true || "$new_hash" != "$old_hash" ]]; then
        echo "$service_name changes detected. Packaging and rebuilding $image_name..."

        package_repo "$repo_dir"

        local docker_build_args=(-t "$image_name")
        if [[ "$NO_CACHE" == true ]]; then
            docker_build_args=(--no-cache "${docker_build_args[@]}")
        fi

        (cd "$repo_dir" && docker build "${docker_build_args[@]}" .)

        if [[ "$PUSH_IMAGE" == true ]]; then
            docker push "$image_name"
        fi

        printf '%s' "$new_hash" > "$state_file"
    else
        echo "No $service_name changes detected. Skipping Maven and Docker build."
    fi
}

mkdir -p "$STATE_DIR"

build_service_if_changed "website" "$APP_DIR" "$WEBSITE_IMAGE_NAME"
build_service_if_changed "commerce" "$COMMERCE_DIR" "$COMMERCE_IMAGE_NAME"

echo "Restarting Docker Compose stack from $INFRA_DIR..."

if [[ "$RESET_VOLUMES" == true ]]; then
    (cd "$INFRA_DIR" && docker compose down -v)
else
    (cd "$INFRA_DIR" && docker compose down)
fi

(cd "$INFRA_DIR" && docker compose up -d)

if [[ "$SEED_DATABASE" == true ]]; then
    echo "Seeding card and store inventory data..."
    if [[ -x "$APP_DIR/MagicDataRetriever/.venv/Scripts/python.exe" ]]; then
        (cd "$APP_DIR/MagicDataRetriever" && ./.venv/Scripts/python.exe databaseIntake.py)
    elif [[ -x "$APP_DIR/MagicDataRetriever/.venv/bin/python" ]]; then
        (cd "$APP_DIR/MagicDataRetriever" && ./.venv/bin/python databaseIntake.py)
    else
        (cd "$APP_DIR/MagicDataRetriever" && python3 databaseIntake.py)
    fi
fi

echo "Done. Website API should be available at http://localhost:8083"
echo "Commerce API should be available at http://localhost:8084"
