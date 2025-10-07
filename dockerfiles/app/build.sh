#!/bin/bash

# Copyright(c) The Maintainers of Nanvix.
# Licensed under the MIT License.

#
# Utility for building a base Nanvix Docker image for use with the nanvix container runtime.
#
# Run './dockerfiles/base/build.sh' to build the Docker image.
#

#==================================================================================================

# Fast fail on errors, unset variables, and pipe failures.
set -euo pipefail

#==================================================================================================
# Imports
#==================================================================================================

# Directory where to find scripts to import.
IMPORT_DIR="$(cd "$(dirname "$0")" && pwd)/../../scripts/common"

source "${IMPORT_DIR}/logging.sh"

#==================================================================================================
# Global Constants
#==================================================================================================

# Directories
REPO_ROOT_DIR=$(git rev-parse --show-toplevel)   
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 

# Default branch name.
#DEFAULT_BRANCH_NAME=$(git -C "${REPO_ROOT_DIR}" remote show origin | awk '/HEAD branch/ {print $NF}')

# Latest commit hash made to the default branch.
# NANVIX_VERSION=$(git -C "${REPO_ROOT_DIR}" rev-parse origin/${DEFAULT_BRANCH_NAME})

# Path to the generated Dockerfile (not tracked in git).
DOCKERFILE_PATH="${SCRIPT_DIR}/Dockerfile.gen"

# NOTE: The Dockerfile is generated to expand CMD to the actual binary name, since Docker exec form does not support runtime variable substitution and there is no shell in the container.

#===================================================================================================
# Main Script
#===================================================================================================

# Print usage instructions
print_usage() {
	echo "Usage: $0 <nanvix_binary> [app_name] [tenant_id] [image_name] [image_tag]"
	echo "Arguments:"
	echo "  nanvix_binary   Nanvix binary filename (required, must match exactly a file in bin/)"
	echo "  app_name        Application name (optional, defaults to nanvix binary name before '.')"
	echo "  tenant_id       Tenant ID (optional)"
	echo "  image_name      Docker image name (optional, defaults to nanvix binary name before '.')"
	echo "  image_tag       Docker image tag (optional, defaults to 'latest')"
}

# Usage: build.sh <nanvix_binary> [app_name] [tenant_id] [image_name] [image_tag]
if [ "$#" -lt 1 ]; then
	print_usage
	exit 1
fi

NANVIX_BINARY="$1"
shift

NANVIXBIN_PATH="${REPO_ROOT_DIR}/bin"
NANVIX_BINARY_PATH="${NANVIXBIN_PATH}/${NANVIX_BINARY}"
if [ ! -f "$NANVIX_BINARY_PATH" ]; then
	print_error "Nanvix binary '${NANVIX_BINARY}' does not exist in ${NANVIXBIN_PATH}. Please provide the exact filename as it appears in the bin directory."
	print_usage
	exit 1
fi

DEFAULT_NAME="${NANVIX_BINARY%%.*}"
DEFAULT_IMAGE_NAME="nanvix-${DEFAULT_NAME}"


# Parse arguments
if [ "$#" -ge 4 ]; then
	APP_NAME="$1"; shift
	TENANT_ID="$1"; shift
	DOCKER_IMAGE_NAME="$1"; shift
	DOCKER_IMAGE_TAG="${1:-latest}"; shift
elif [ "$#" -ge 3 ]; then
	APP_NAME="$1"; shift
	TENANT_ID="$1"; shift
	DOCKER_IMAGE_NAME="$DEFAULT_IMAGE_NAME"
	DOCKER_IMAGE_TAG="${1:-latest}"; shift
elif [ "$#" -ge 2 ]; then
	APP_NAME="$DEFAULT_NAME"
	TENANT_ID="$1"; shift
	DOCKER_IMAGE_NAME="$DEFAULT_IMAGE_NAME"
	DOCKER_IMAGE_TAG="${1:-latest}"; shift
elif [ "$#" -ge 1 ]; then
	APP_NAME="$DEFAULT_NAME"
	TENANT_ID=""
	DOCKER_IMAGE_NAME="$DEFAULT_IMAGE_NAME"
	DOCKER_IMAGE_TAG="${1:-latest}"; shift
else
	APP_NAME="$DEFAULT_NAME"
	TENANT_ID=""
	DOCKER_IMAGE_NAME="$DEFAULT_IMAGE_NAME"
	DOCKER_IMAGE_TAG="latest"
fi


print_info "Generating Dockerfile with expanded CMD for binary: ${NANVIX_BINARY}..."
cat > "${DOCKERFILE_PATH}" <<EOF
FROM nanvix-base:${DOCKER_IMAGE_TAG}
ENV NANVIX_TENANT_ID="${TENANT_ID:-default}"
ENV NANVIX_APP_NAME="${APP_NAME:-default}"
COPY ./bin/${NANVIX_BINARY} /nanvixbin/${NANVIX_BINARY}
CMD ["/nanvixbin/${NANVIX_BINARY}"]
EOF


print_info "Building Nanvix App Docker image..."
docker build \
	-t "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" \
	-f "${DOCKERFILE_PATH}" \
	"${REPO_ROOT_DIR}"

print_success "Successfully built Docker image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}."

