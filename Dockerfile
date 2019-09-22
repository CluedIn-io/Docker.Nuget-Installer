ARG VERSION=1803
ARG TYPE=windowsservercore
FROM mcr.microsoft.com/powershell:6.2.3-${TYPE}-${VERSION}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]

RUN Invoke-WebRequest -OutFile /nuget.exe -Uri https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

WORKDIR /scripts

COPY Install-Packages.ps1 .
