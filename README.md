# DkML Docker Containers

DkML Docker Containers are a set of open-source containers available from:

- The GitHub Package Registry. For example, `docker pull ghcr.io/diskuv/avalonia-browser-base:edge`
- The GitLab Container Registry. It requires authentication. For example, `docker login -u ... -p ...` and `docker pull registry.gitlab.com/dkml/base/containers/avalonia-browser-base:edge`

## image: avalonia-browser-base

This is a container with [Avalonia UI](https://avaloniaui.net/) that has:

- .NET 8.0 and .NET 9.0
- .NET WASM workload for .NET 8
- Python 3
- The Skia 2-D graphics pre-requisites for Avalonia Preview in the Avalonia Visual Studio Code extension
- The Jutjutsu `jj` source control tool
- The DkCoder `dk` tool
- The .NET `nuke` tool
- Avalonia 11.3.0 with a patch for <https://github.com/AvaloniaUI/Avalonia/pull/18950>

## image: avalonia-android-base

This is a container with [Avalonia UI](https://avaloniaui.net/) that has:

- .NET 8.0 and .NET 9.0
- .NET Android workload
- Python 3
- The Skia 2-D graphics pre-requisites for Avalonia Preview in the Avalonia Visual Studio Code extension
- The Jutjutsu `jj` source control tool
- The DkCoder `dk` tool
- The .NET `nuke` tool
- Avalonia 11.3.0 with a patch for <https://github.com/AvaloniaUI/Avalonia/pull/18950>
