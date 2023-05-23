[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $rehearsalName,

    [Parameter(Mandatory=$false)]
    [string]
    $outputRootPath="$PSScriptRoot/../git-rehearsal-output",

    [Parameter(Mandatory=$false)]
    [string]
    $rehearsalRootPath="$PSScriptRoot/rehearsals",

    [switch]
    $useDocker
)

if ($useDocker) {
    . ./DockerGitVersion.ps1
} else {
    . ./DotnetGitVersion.ps1
}

. ./GitRehearsal.ps1

$rehearsalFile = "${rehearsalRootPath}/$rehearsalName.ps1"
if (-Not (Test-Path $rehearsalFile -PathType Leaf)) {
    throw "No rehearsal file found at $rehearsalFile"
}

$dateStr=Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$targetDir="${outputRootPath}/rehearsal-${rehearsalName}-${dateStr}"


Write-Verbose "Creating repo in directory $targetDir...."

New-Item -ItemType Directory -Path $targetDir | Out-Null

$rehearsalVersionConfig = "${rehearsalRootPath}/$rehearsalName-gitversion.yml"
if ((Test-Path $rehearsalVersionConfig)) {
    Copy-Item $rehearsalVersionConfig "${targetDir}/GitVersion.yml" | Out-Null
}

Start-GitVersion $targetDir

Push-Location -Path $targetDir

try {
    git init
    Write-Verbose "Running rehearsal in $rehearsalFile...."
    &$rehearsalFile
}
finally {
    Stop-GitVersion
    Pop-Location
}

