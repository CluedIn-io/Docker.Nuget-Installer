#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [String]$UserName = "VssSessionToken",
    [String]$Key = $env:KEY,
    [String[]]$FeedNames = $null,
    [String]$PackageListFile = (Join-Path -Path $PSScriptRoot -ChildPath "Packages.txt"),
    [String]$OutputDir = (Join-Path -Path $PSScriptRoot -ChildPath "packages"),
    [String]$NugetConfig = (Join-Path -path $PSScriptRoot -ChildPath 'nuget.config'),
    [String]$TargetFramework = 'net452'
)

# Get the packages
$resolvedPackagePath = Resolve-Path $PackageListFile
$packages = Get-Content ($resolvedPackagePath.Path) | 
    ForEach-Object {
        $id,$version = $_ -split ' '        
        if(!$version) {            
            Write-Warrning "No version found for package $id. Using latest release version instead."
            # TODO: When *-* is supported change to default version
            $version = '*'
        }
        [PSCustomObject]@{
            Id = $id
            Version = $version
        }
    }



# Configure NuGet
$resolvedNugetPath = Resolve-Path $NugetConfig
if($FeedNames -And $Key){
    $FeedNames | ForEach-Object {
        dotnet nuget update source $_ -u $UserName -p $Key --configfile $resolvedNugetPath
    }
}

# Dotnet restore
$projectName = "Project$([Guid]::NewGuid().ToString("N"))"
$projectPath = Join-Path $PSScriptRoot $projectName
# We could use the dotnet cli but... it's slow.
# We could use System.Xml but we're doing some basic things.
# Just use here-strings.
$projectContents = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>${TargetFramework}</TargetFramework>
    <Configuration>Release</Configuration>
    <DebugType>None</DebugType>
  </PropertyGroup>
  <ItemGroup>
  $($packages | ForEach-Object {
    "<PackageReference Include='$($_.Id)' Version='$($_.Version)' />$([Environment]::NewLine)"    
    })
  </ItemGroup>
</Project>
"@

New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
$projectContext | Set-Content (Join-Path $projectPath "${projectName}.csproj")

# Perform the restore
dotnet publish $projectPath -o $OutputDir
Write-Output "Restored Files:"
Get-ChildItem $OutputDir -Recurse | Select-Object -ExpandProperty Name
