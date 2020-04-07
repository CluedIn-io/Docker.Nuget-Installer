ARG VERSION=3.1
FROM mcr.microsoft.com/dotnet/core/sdk:${VERSION}

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]

WORKDIR /scripts

COPY install-packages.ps1 .
