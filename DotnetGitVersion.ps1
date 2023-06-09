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
            "version": "5.12.0",
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
    param (
        [string]
        $configFile
    )

    $opts = "gitversion", ".", "/nocache"
    if ($configFile) {
        $opts += "/config", $configFile
    }

    Write-Debug ($opts -join " ")
    exec {
        $output = dotnet @opts
        $output | Write-Debug
        $output | ConvertFrom-Json
    }
}