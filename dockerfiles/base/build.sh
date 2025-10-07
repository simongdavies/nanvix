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
#REPO_LOGS_DIR="${REPO_ROOT_DIR}/logs" 

# Default branch name.
DEFAULT_BRANCH_NAME=$(git -C "${REPO_ROOT_DIR}" remote show origin | awk '/HEAD branch/ {print $NF}')

# Latest commit hash made to the default branch.
NANVIX_VERSION=$(git -C "${REPO_ROOT_DIR}" rev-parse origin/${DEFAULT_BRANCH_NAME})

# Dockerfile path.
DOCKERFILE_PATH="${SCRIPT_DIR}/Dockerfile"

# Default name for the Docker image.
DOCKER_IMAGE_NAME="nanvix-base"

# Default tag for the Docker image.
DOCKER_IMAGE_TAG="latest"


#==================================================================================================
# Functions
#==================================================================================================

# Clone and build minijail0
clone_and_build_minijail() {
	local MINIJAIL_REPO="https://github.com/google/minijail.git"
	local MINIJAIL_DIR="${REPO_ROOT_DIR}/build-minijail"
	if [ ! -d "$MINIJAIL_DIR" ]; then
		print_info "Cloning minijail repository..."
		git clone "$MINIJAIL_REPO" "$MINIJAIL_DIR"
	else
		print_info "Minijail directory already exists, pulling latest changes..."
		git -C "$MINIJAIL_DIR" pull
	fi
	print_info "Building minijail..."
	make -C "$MINIJAIL_DIR" OUT="$MINIJAIL_DIR" > /dev/null
	print_success "Minijail built successfully."
}

# Build the Docker image
build_docker_image() {
	docker build \
		--build-arg NANVIX_VERSION="${NANVIX_VERSION}" \
        --build-arg MINIJAIL_PATH="./build-minijail" \
        --build-arg NANVIXBIN_PATH="./bin" \
		-t "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" \
		-f "${DOCKERFILE_PATH}" \
		"${REPO_ROOT_DIR}"
}

#===================================================================================================
# Main Script
#===================================================================================================

# Clone and build minijail0

print_info "Building base Nanvix Docker image..."

print_info "Step 1/2: Cloning and building minijail0..."

clone_and_build_minijail

print_info "Step 2/2: Building Docker image..."

# Build the Docker image
build_docker_image

print_success "Successfully built Docker image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}."