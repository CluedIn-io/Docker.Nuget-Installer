FROM mcr.microsoft.com/powershell:windowsservercore-1803

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]

RUN Invoke-WebRequest -OutFile /nuget.exe -Uri https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

WORKDIR /scripts

COPY Install-Packages.ps1 .