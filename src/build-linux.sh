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
.
------
Matrix
------
SUBPROJECT=$SUBPROJECT
.
"

cd "src/$SUBPROJECT/linux"
cat Dockerfile

# Inspect Dockerfile
IMAGE_TAG=$(grep -E '^#:: VERSION=.*$' Dockerfile | awk 'BEGIN{FS="="} { print $2 }')
if [ -z "$IMAGE_TAG" ]; then echo "'#:: VERSION=<version>' missing from Dockerfile"; exit 1; fi
echo "LABEL commit=$CI_COMMIT_SHA" | tee -a Dockerfile
export IMAGE_NAME="$CI_REGISTRY_IMAGE/$SUBPROJECT"
export IMAGE_URI="$IMAGE_NAME:$IMAGE_TAG"

# Create and push container
echo "image uri: $IMAGE_URI"
docker context create builder
docker buildx create builder --use
time docker buildx build \
    --platform linux/amd64 \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    "--cache-from=type=registry,ref=$IMAGE_NAME:buildcache" \
    "--cache-to=type=registry,ref=$IMAGE_NAME:buildcache,mode=max,image-manifest=true,oci-mediatypes=true" \
    -t "$IMAGE_URI" \
    --push .
