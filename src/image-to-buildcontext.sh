#!/bin/sh
set -eufx

case "$IMAGE_NAME" in
    avalonia-browser-base)
        export DOCKER_CONTEXT_NAME=avalonia-base
        export DOTNET_WORKLOADS=wasm-tools-net8 ;;
    avalonia-android-base)
        export DOCKER_CONTEXT_NAME=avalonia-base
        export DOTNET_WORKLOADS=android ;;
esac
