param(
    [string]$UserName="VssSessionToken",
    [string]$Key=$env:KEY,
    [string[]]$FeedNames,
    [string]$PackageListFile="Packages.txt",
    [string]$nuget="\nuget.exe",
    [string]$outputDir="\packages",
    [string]$nugetConfig
)

$root = $PSScriptRoot

if (-Not($PackageListFile)){
    $PackageListFile = (Join-Path -Path $root -ChildPath "Packages.txt")
}

if(-Not(Test-Path $PackageListFile)){
    throw "Package list file $PackageListFile not found"
}

if (-Not($nugetConfig)){
    $nugetConfig = (Join-Path -path $root -ChildPath 'nuget.config')
}

if(-Not(Test-Path $nugetConfig)){
    throw "nuget.config not found"
}
# List nuget packages to download
$packages = $(get-content $PackageListFile)

if($FeedNames -And $Key){
    $FeedNames | ForEach-Object {
        & $nuget sources update -Name $_ -UserName $UserName -Password $Key -configfile $nugetConfig
    }

}

New-Item -ItemType Directory -Path $outputDir -Force

$packages | ForEach-Object {
    write-output "Trying to install $_"
    & $nuget install $_ -prerelease -outputDirectory $outputDir -configfile $nugetConfig -NonInteractive
    if (-not $? ) {
        Write-Output "##vso[task.logissue type=error]Could not install package $_."
        exit 1
    }
}

# Flatten all dlls from all packages into root folder

Push-Location $outputDir
Get-ChildItem *.dll -Recurse | Move-Item -Destination . -Force
Get-ChildItem -Directory | Remove-Item -Force -Recurse
Write-Output "List of files in the $outputDir folder"
Get-ChildItem
Pop-Location

