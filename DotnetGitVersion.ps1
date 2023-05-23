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
        $repoPath
    )

    $config = 
@"
    {
        "version": 1,
        "isRoot": true,
        "tools": {
          "gitversion.tool": {
            "version": "5.10.3",
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
        $output = dotnet gitversion 
        Write-Debug "$output"
        $output | ConvertFrom-Json
    }
}