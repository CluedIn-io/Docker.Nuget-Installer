ARG VERSION=1809
ARG TYPE=nanoserver
FROM mcr.microsoft.com/dotnet/core/sdk:3.1.201-${TYPE}-${VERSION}

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]

WORKDIR /scripts

COPY install-packages.ps1 .
