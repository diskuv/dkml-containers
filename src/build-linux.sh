#!/bin/sh
set -euf

echo "
==============
build-linux.sh
==============
.
------
Input
------
CI_JOB_ID=$CI_JOB_ID
CI_REGISTRY_IMAGE=$CI_REGISTRY_IMAGE
CI_COMMIT_SHA=$CI_COMMIT_SHA
CI_PROJECT_URL=$CI_PROJECT_URL
CI_JOB_STARTED_AT=$CI_JOB_STARTED_AT
.
------
Matrix
------
IMAGE_NAME=$IMAGE_NAME
.
-------
Derived
-------
DOCKER_CONTEXT_NAME=$DOCKER_CONTEXT_NAME
DOTNET_WORKLOADS=$DOTNET_WORKLOADS
.
"

# Inspect Dockerfile
#   SYNC: src/build-linux.sh, .github/workflows/deploy-image.yml:jobs/build-and-push-image/steps[id=version]
IMAGE_TAG=$(grep -E '^#:: VERSION=.*$' "src/$DOCKER_CONTEXT_NAME/linux/Dockerfile" | awk 'BEGIN{FS="="} { print $2 }')
if [ -z "$IMAGE_TAG" ]; then echo "'#:: VERSION=<version>' missing from src/$DOCKER_CONTEXT_NAME/linux/Dockerfile"; exit 1; fi

# Change to the Docker context directory. Makes docker commands simple
cd "src/$DOCKER_CONTEXT_NAME/linux"

# Add labels to Dockerfile
cat Dockerfile
echo "LABEL org.opencontainers.image.source=$CI_PROJECT_URL" | tee -a Dockerfile
echo "LABEL org.opencontainers.image.revision=$CI_COMMIT_SHA" | tee -a Dockerfile
echo "LABEL org.opencontainers.image.created=$CI_JOB_STARTED_AT" | tee -a Dockerfile
echo "LABEL org.opencontainers.image.licenses=Apache-2.0" | tee -a Dockerfile
export IMAGE_NAME="$CI_REGISTRY_IMAGE/$IMAGE_NAME"
export IMAGE_URI="$IMAGE_NAME:$IMAGE_TAG"
export IMAGE_EDGE="$IMAGE_NAME:edge"

# Create and push container
echo "__ pushing container __"
echo "image uri: $IMAGE_URI"
docker context create builder
docker buildx create builder --use
#   SYNC: src/build-linux.sh, .github/workflows/deploy-image.yml:jobs/build-and-push-image/steps[id=push]
time docker buildx build \
    --platform linux/amd64 \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --build-arg "DOTNET_WORKLOADS=$DOTNET_WORKLOADS" \
    "--cache-from=type=registry,ref=$IMAGE_NAME:buildcache" \
    "--cache-to=type=registry,ref=$IMAGE_NAME:buildcache,mode=max,image-manifest=true,oci-mediatypes=true" \
    -t "$IMAGE_URI" -t "$IMAGE_EDGE" \
    --push .
