function exec {
    param ($command)
    & $command
    if ($LASTEXITCODE -gt 0) {
        throw "### GitVersion failed : $LASTEXITCODE ###"
    }
}

function Start-GitVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]
        $repoPath,

        [string]
        $version = "5.12.0"
    )

    $config = 
@"
    {
        "version": 1,
        "isRoot": true,
        "tools": {
          "gitversion.tool": {
            "version": "$version",
            "commands": [
              "dotnet-gitversion"
            ]
          }
        }
    }
"@

    New-Item $repoPath/.config -ItemType Directory | Out-Null
    Set-Content -Path $repoPath/.config/dotnet-tools.json -Value $config

    Push-Location $repoPath
    try {
        exec { dotnet tool restore }
    } finally {
        Pop-Location
    }
}

function Stop-GitVersion {
}

function Invoke-GitVersion {
    [CmdletBinding()]
    param ()

    exec {
        $output = dotnet gitversion /output json /verbosity quiet | Out-String
        if ($LASTEXITCODE -gt 0) {
            dotnet gitversion /output json /verbosity Diagnostic /diag | Out-File -FilePath gitversion.log
            throw "Gitversion failed! ($LASTEXITCODE). See gitversion.log in $(Get-Location) for details."
        }

        Write-Debug "$output"

        $output.SubString($output.IndexOf('{')) | ConvertFrom-Json
    }
}