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

    exec {
        docker run -d --rm `
            -v "${repoPath}:/repo" `
            --name "git-rehearsal" `
            --entrypoint /bin/sleep `
            gittools/gitversion:$version `
            infinity
    }
}

function Stop-GitVersion {
    exec { docker container stop "git-rehearsal" }
}

function Invoke-GitVersion {
    [CmdletBinding()]
    param ()

    exec {
        $output = docker exec git-rehearsal /tools/dotnet-gitversion /repo /output json /verbosity quiet
        $output.SubString($output.IndexOf('{')) | ConvertFrom-Json
    }
}