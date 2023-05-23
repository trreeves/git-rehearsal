function exec {
    param ($command)
    & $command
    if ($LASTEXITCODE -gt 0) {
        throw "### Git failed : $LASTEXITCODE ###"
    }
}

function Set-GitBranchName {
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $branchName,

        [Parameter(Mandatory=$true)]
        [string]
        $newName
    )
    Write-Verbose "Set-GitBranchName"
    exec { git branch -m $branchName $newName }
}

function Add-GitCommit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $file,

        [Parameter(Mandatory=$false)]
        [string]
        $value,

        [Parameter(Mandatory=$true)]
        [string]
        $message,

        [string]
        $branch
    )

    Write-Verbose "Add-GitCommit"
    if ([System.String]::IsNullOrEmpty($value)) {
        $value = $message
    }

    if ($branch) {
        exec { git checkout $branch }
    }

    Add-Content -Path $file -Value $value
    exec { git add . }
    exec { git commit -m $message }

    $versionInfo = Invoke-GitVersion
    exec { git commit --amend -m "$message [$($versionInfo.FullSemVer)]`n`n$($versionInfo | ConvertTo-Json)" }
}

function New-GitTag {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $tagName
    )
    Write-Verbose "New-GitTag"
    exec { git tag $tagName }
}

function New-GitBranch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $branchName,

        [string]
        $sourceBranch
    )

    Write-Verbose "New-GitBranch"
    if ($sourceBranch) {
        exec { git checkout $sourceBranch }
    }

    exec { git branch $branchName }
    exec { git checkout $branchName }
}

function New-GitMerge {
    [CmdletBinding()]
    param (
        [string]
        $sourceBranch,

        [Parameter(Mandatory=$true)]
        [string]
        $targetBranch,

        [Parameter()]
        [switch]
        $deleteSource=$false
    )

    Write-Verbose "New-GitMerge"
    
    if (-Not $sourceBranch) {
        $sourceBranch = exec { git branch --show-current }
    }
    
    $message = "Merge branch '$sourceBranch' into $targetBranch"
    exec { git checkout $targetBranch }
    exec { git merge $sourceBranch --no-ff -m $message  }

    $versionInfo = Invoke-GitVersion
    exec { git commit --amend -m "$message [$($versionInfo.FullSemVer)]`n`n$($versionInfo | ConvertTo-Json)" }

    if ($deleteSource) {
        git branch -d $sourceBranch
    }
}