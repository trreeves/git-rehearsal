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

    exec {
        docker run -d --rm `
            -v "${repoPath}:/repo" `
            --name "git-rehearsal" `
            --entrypoint /usr/bin/sleep `
            gittools/gitversion:5.12.0 `
            infinity
    }
}

function Stop-GitVersion {
    exec { docker container stop "git-rehearsal" }
}

function Invoke-GitVersion {
    [CmdletBinding()]
    param (
        [string]
        $configFile
    )

    $opts = "/repo", "/nocache"
    if ($configFile) {
        $opts += "/config", $configFile
    }

    Write-Debug ($opts -join " ")

    exec {
        $output = docker exec git-rehearsal /tools/dotnet-gitversion @opts `
        $output | Write-Debug
        $output | ConvertFrom-Json
    }
}