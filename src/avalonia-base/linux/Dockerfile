# ===================
# IF CHANGES ARE MADE
# ===================
#
# Increment the Serial number in VERSION=Major.Minor.Patch.Serial.
# Examples:
#   1.0.0.1 -> 1.0.0.2 -> 1.1.0.3 -> 1.2.0.4

# Container: Debian Bookworm (12) for semantic versions `dotnet.1.x.x`
# Why?
#   We use .NET 9.0 even though the *.csproj target dotnet8 so
#   the C# extension does not waste time installing 9.0 (apparently
#   the C# language server or whatever uses 9.0).
# Alternatives considered?
#   Instead of a custom Dockerfile, an alternate path could be adding
#   'postCreateCommand' to devcontainer.json. But the C# extension will load in
#   parallel with the 'postCreateCommand', so C# may give a race-condition error
#   "Failed to restore NuGet packages for the solution." since required dotnet
#   workloads have not been installed.
# Bonus:
#   1. The `vscode(1000)` non-root user will be created for us.
#      Confer: https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user
FROM mcr.microsoft.com/devcontainers/dotnet:1-9.0-bookworm

#   wasm-tools-net8: ScoutTrainingApp.Browser (aka.
#       'wasm-tool' if we had dotnet version 8.0 as the dotnet executable)
#   android: ScoutTrainingApp.Android
RUN sudo dotnet workload install wasm-tools-net8 android

#   https://github.com/dotnet/emsdk used by wasm-tools has an
#   implicit system dependency on Python
RUN sudo apt-get update && sudo apt-get install -y python3

#   Install dotnet 8 since Avalonia Preview needs 8 (likely because
#   the csproj is 8). Both dotnet 8 and 9 can co-exist.
#   Reference: https://learn.microsoft.com/en-us/dotnet/core/install/linux-debian?tabs=dotnet8
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb
RUN sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0

#   The Avalonia Preview binds to localhost and can't be done correctly in a remote PC like GitHub Codespaces.
#   But if running the devcontainer locally, we'd first encounter the following ... which we need to avoid:
#     2025-05-24 03:45:08.379 [info] System.TypeInitializationException: The type initializer for 'SkiaSharp.SKImageInfo' threw an exception.
#     ---> System.DllNotFoundException: Unable to load shared library 'libSkiaSharp' or one of its dependencies. In order to help diagnose loading problems, consider using a tool like strace. If you're using glibc, consider setting the LD_DEBUG environment variable: 
#     libfontconfig.so.1: cannot open shared object file: No such file or directory
#     /usr/share/dotnet/shared/Microsoft.NETCore.App/8.0.16/libSkiaSharp.so: cannot open shared object file: No such file or directory
RUN sudo apt-get install -y libfontconfig1

#   Useful tools ...

#   jj: https://jj-vcs.github.io/jj/latest/install-and-setup/
RUN sudo wget -O jj.tar.gz https://github.com/jj-vcs/jj/releases/download/v0.29.0/jj-v0.29.0-x86_64-unknown-linux-musl.tar.gz && \
    tar xCfz /usr/local/bin jj.tar.gz ./jj && \
    rm jj.tar.gz && \
    command -v jj

#   dk: https://github.com/diskuv/dkcoder
RUN sudo wget -O /usr/local/bin/dk https://diskuv.com/a/dk-distribution/2.3.202505280211/dist/dk-linux_x86_64 && \
    sudo chmod +x /usr/local/bin/dk

#   xpra: https://github.com/Xpra-org/xpra/wiki/Download#-for-debian-based-distributions
# RUN sudo wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc
# RUN sudo sh -c 'cd /etc/apt/sources.list.d && wget https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/bookworm/xpra-lts.sources'
# RUN sudo apt update && sudo apt install -y xpra

#   caddy
# RUN sudo wget -O caddy.tar.gz https://github.com/caddyserver/caddy/releases/download/v2.10.0/caddy_2.10.0_linux_amd64.tar.gz && \
#     tar xCfz /usr/local/bin caddy.tar.gz caddy && \
#     rm caddy.tar.gz && \
#     command -v caddy

#   --------------
#   BUILD AVALONIA
#   --------------

#   The version number should be the Avalonia Major.Minor.Patch version, followed by a .Serial number
#   which is the sequence number of changes to this Dockerfile. Always increment the .Serial number when
#   changing the Dockerfile!
#
#   format: Do not change format! Must be `#:: VERSION=<version>` since part of `grep -E` in ci/gitlab/util-*.yml
#:: VERSION=11.3.0.1

#   Prerequisites for building Avalonia ...
#
#   'nuke'
RUN dotnet tool install --global Nuke.GlobalTool --version 6.2.1
ENV PATH="${PATH}:/root/.dotnet/tools"

#   https://github.com/AvaloniaUI/Avalonia/blob/master/Documentation/build.md
#   + Patch for letting localhost proxied web browsers into GitHub Codespaces.
#     https://github.com/AvaloniaUI/Avalonia/pull/18950
RUN git clone https://github.com/jonahbeckford/Avalonia.git /usr/src/Avalonia && \
    git -C /usr/src/Avalonia reset --hard 71618b9150bf582fd98975d39f6125c3d5417f45 && \
    OLDPWD=$(pwd) && cd /usr/src/Avalonia && \
    git submodule update --init --recursive && \
    sudo apt-get install -y npm && \
    nuke --target BuildToNuGetCache --configuration Debug && \
    cd $OLDPWD
