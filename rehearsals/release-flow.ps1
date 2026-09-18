# Release Flow
# A branching model suited to a product requiring historic version support. See http://releaseflow.org/

# Overview:
# - Ongoing feature development is performed on 'main'. 
# - Releases are managed via 'release/x.y/main' branches, which are created at the start of release hardening phase. 
#   This is when the Team City build configuration is to cloned/forked.
# - Release hardening changes will typically be performed on 'main'
#   first, then cherry-picked to the release branch via feature branches
# - The release itself is handled by selecting a commit from the release branch, then tagging that commit with the release version.
# - Hotfixes are performed with subsequent changes to the 'release/x.y/main' branch, and hotfix release are performed identically to 
#   the 'normal' releases.
# - The main release branches are preserved forever - or until that release strain is completely redundant.

# Synopsis: Perform some new feature work for vnext
function Invoke-FeatureBranchWork {
    param(
        [string]$featureName,
        [string]$targetBranch,
        [switch]$skipMerge)

    $featureBranchName = "feature/$featureName"
    $null = New-GitBranch $featureBranchName -SourceBranch $targetBranch
    $null = Add-GitCommit ./info.txt -Message "$featureName - changes - 1"
    $null = Add-GitCommit ./info.txt -Message "$featureName - changes - 2"
    if (-not $skipMerge) {
        $null = New-GitMerge -SourceBranch $featureBranchName -TargetBranch $targetBranch
    }
    $featureBranchName
}

# Synopsis: Start a new supported release strain for a 'major.minor' pair.
function Invoke-InitReleaseBranch {
    param([string]$version)

    $branchName = "release/$version/main"
    $null = Set-GitBranch main
    $null = New-GitBranch $branchName

    # Perform an empty commit to establish the root of the release branch
    # This commit ensures that pull requests branches at the start of the release branch
    # recieve the correct version; it allows GitVersion to correctly determine the correct parent branch.
    $null = Add-GitCommit ./info.txt -Message "Release-Flow: Initialize release branch : $branchName"

    # To ensure that any commits on a release-feature branch, and on pull request branches,
    # for the first release on a release branch, get the correct version number generated, this tag is required at the 
    # root of the release branch.
    #
    # Otherwise the major.minor.path is not right; this is because there is no reliable way for GitVersion to determine
    # major.minor.patch - it can't reliably determine it from the graph.
    # Incidently, you see this same situation occur with GitFlow, for the feature branches taken off the first ever release branch.
    # Though with Gitflow this never occurs with subsequent release branches because there's merge commits in the graph that
    # act as 'version anchors'.

    $null = New-GitTag "rc/v$((Invoke-GitVersion).MajorMinorPatch)-rc.0"

    $branchName
}

# Synopsis: Start a new beta strain for a 'major.minor' pair.
function Invoke-InitBetaBranch {
    param([string]$version, [string]$betaName)

    $branchName = "beta/$version/$betaName"
    $null = Set-GitBranch main
    $null = New-GitBranch $branchName

    $branchName
}

# Synopsis: Perform release hardening changes via 'fix' branches on a release branch
function Invoke-ReleaseFixWork {
    param(
        [string]$fixName,
        [string]$version,
        [switch]$skipMerge)

    $branchName = "release/$version/fix/$fixName"
    $null = New-GitBranch "release/$version/fix/$fixName" -SourceBranch "release/$version/main"
    $null = Add-GitCommit ./info.txt -Message "$fixName - changes - 1"
    $null = Add-GitCommit ./info.txt -Message "$fixName - changes - 2"

    if (-Not $skipMerge) {
        $null = New-GitMerge -TargetBranch "release/$version/main"
    }

    $branchName
}

$global:pullCounter = 100

function Invoke-PublishPullRequest {
    param(
        [string]$source,
        [string]$target
    )

    $null = Set-GitBranch $target
    $global:pullCounter = $global:pullCounter + 1
    $pullBranch = "pull/$pullCounter/merge"
    $null = New-GitBranch -BranchName $pullBranch -SourceBranch $target
    $null = New-GitMerge -SourceBranch $source -TargetBranch $pullBranch
    $pullBranch
}

# Synopsis: Perform the release for the current commit on the release branch
function Invoke-PerformRelease {
    param([string]$version)

    $null = New-GitTag "v$((Invoke-GitVersion).MajorMinorPatch)" -SourceBranch "release/$version/main"
}

function Invoke-PerformBetaRelease {
    param([string]$betaBranch)

    $null = Set-GitBranch $betaBranch
    $null = New-GitTag "beta/$((Invoke-GitVersion).SemVer)"
}

# ------------

Set-GitBranchName master main
Add-GitCommit  ./info.txt "init" "init"

# vnext feature work on main

Invoke-FeatureBranchWork "story_a" main
Invoke-FeatureBranchWork "story_b" main

# Start release hardening phase for 1.0.0

Invoke-InitReleaseBranch "1.0"
Invoke-ReleaseFixWork "m" "1.0"

# Concurrent dev work for vnext on main

Invoke-FeatureBranchWork "story_c" main

# More release hardening and then the release of 1.0.0

Invoke-ReleaseFixWork "n" "1.0"
Invoke-PerformRelease "1.0"

# More dev work on main

Invoke-FeatureBranchWork "story_d" main

# New 'Minor' release (1.1.0) hardening phase and release

Invoke-InitReleaseBranch "1.1"
Invoke-ReleaseFixWork "o" "1.1"
Invoke-PerformRelease "1.1"

# More dev work on main

Invoke-FeatureBranchWork "story_e" main

# Patch/hotfix release release for 1.0 (1.0.1)
Invoke-ReleaseFixWork "p" "1.0"
Invoke-PerformRelease "1.0"

$q = Invoke-ReleaseFixWork "q" "1.0" -skipMerge
$r = Invoke-ReleaseFixWork "r" "1.0" -skipMerge

Invoke-PublishPullRequest -Source $q -Target "release/1.0/main"
Invoke-PublishPullRequest -Source $r -Target "release/1.0/main"

# New major release, with first pull request

$release_2_0 = Invoke-InitReleaseBranch "2.0"
$s = Invoke-ReleaseFixWork "s" "2.0" -skipMerge
Invoke-PublishPullRequest -Source $s -Target $release_2_0

# Ongoing work on main
Set-GitBranch main
Add-GitCommit ./info.txt -Message "main work 1"
Add-GitCommit ./info.txt -Message "main work 2"

# BetaA release
$betaA = Invoke-InitBetaBranch "2.1" "betaA"

## BetaA - First PR
$f_betaA = Invoke-FeatureBranchWork "story_f_bA" $betaA -skipMerge
Add-GitCommit ./beta.txt -Message "betaA work 1"
Invoke-PublishPullRequest -Source $f_betaA -Target $betaA

## BetaA - Feature branch merged
Set-GitBranch $betaA
Invoke-FeatureBranchWork "story_g_bA" -Target $betaA

## BetaA - first release
Invoke-PerformBetaRelease $betaA
Add-GitCommit ./beta.txt -Message "betaA work 2"

# Ongoing work on main
Set-GitBranch main
Add-GitCommit ./info.txt -Message "main work 1"
Add-GitCommit ./info.txt -Message "main work 2"

