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
$packages = $(get-content $PackageListFile) | ForEach-Object {
    $name,$version = $_.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    [PSCustomObject]@{
        Name = $name
        Version = $version
    }
}

if($FeedNames -And $Key){
    $FeedNames | ForEach-Object {
        & $nuget sources update -Name $_ -UserName $UserName -Password $Key -configfile $nugetConfig
    }

}

New-Item -ItemType Directory -Path $outputDir -Force

$packages | ForEach-Object {
    $nugetArgs = @(
        'install', $_.Name
        '-OutputDirectory', $outputDir
        '-configFile', $nugetConfig
        '-DependencyVersion', 'Ignore'
        '-NonInteractive'
        '-Prerelease'
    )

    $idStub = $_.Name

    if($_.Version) {
        $nugetArgs += @('-Version', $_.Version)
        $idStub += " [$($_.Version)]"
    }

    Write-Output $message = "Trying to install ${idStub}"
    & $nuget $nugetArgs
    if (-not $? ) {
        Write-Output "##vso[task.logissue type=error]Could not install package ${idStub}."
        exit 1
    }
}

# Flatten all dlls from all packages into root folder

Push-Location $outputDir
Get-ChildItem *\lib\net452\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *\lib\net451\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *\lib\net45\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *\lib\net403\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *\lib\net40\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *\lib\net35\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *\lib\net20\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *\lib\net11\*.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem *.dll -Recurse | Move-Item -Destination . -ErrorAction SilentlyContinue
Get-ChildItem -Directory | Remove-Item -Force -Recurse
Write-Output "List of files in the $outputDir folder"
Get-ChildItem
Pop-Location

