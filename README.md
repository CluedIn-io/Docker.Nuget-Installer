# Nuget installer image

The purpose of this Windows image is to use it as part of a builder pattern to retrieve some nuget packages and be able to copy them to another image.

## Usage

Use it as a base image as part of a builder pattern, e.g.:

```Dockerfile
FROM cluedin/nuget-installer as nuget

ARG KEY

COPY . .

RUN ./Install-Packages.ps1 -FeedNames @('develop','CluedIn')

FROM cluedin/cluedin-server:develop_20190407.6

COPY --from=nuget /packages/*.dll /app/ServerComponent/
```

The image expects two files to be copied, a `Packages.txt` that contains the names of the Nuget packages to install (one per line), and a `nuget.config` with the configuration of the sources to use.

Optionally, if you supply a `-FeedNames` parameter it will use the build argument `KEY` to as the ApiKey to access those feeds.

The packages are copied to the `/packages` folder (though that can be changed with the `-outputDir` parameter).
