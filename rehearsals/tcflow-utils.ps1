# A branching model suited to a product requiring historic version support, with Team City build chains.

# Overview:
# - Ongoing feature development is performed on 'develop'. 
# - Releases are managed via 'release/x.y/main' branches, which are created at the start of release hardening phase. 
#   This is when the Team City build configuration is to cloned/forked.
# - Release hardening changes are performed via 'release/x.y/fix/<name>' branches.
# - The release itself is handled by selecting a commit from the release branch, then tagging that commit with the release version.
# - Hotfixes are performed with subsequent changes to the 'release/x.y/main' branch, and hotfix release are performed identically to 
#   the 'normal' releases.
# - The main release branches are preserved forever.

# Synopsis: Perform some new feature work for vnext
function Invoke-FeatureBranchWork {
    param(
        [string]$featureName,
        [string]$targetBranch,
        [string]$prefix = "",
        [string]$gitVersionConfig = "")

    New-GitBranch "${prefix}feature/$featureName" -SourceBranch $targetBranch
    Add-GitCommit ./info.txt -Message "$featureName - changes - 1" -GitVersionConfig $gitVersionConfig
    Add-GitCommit ./info.txt -Message "$featureName - changes - 2" -GitVersionConfig $gitVersionConfig
    New-GitMerge -TargetBranch $targetBranch -GitVersionConfig $gitVersionConfig
}

# Synopsis: Start a new supported release strain for a 'major.minor' pair.
function Invoke-InitReleaseBranch {
    param(
        [string]$version,
        [string]$prefix = "",
        [string]$tagprefix = "c",
        [string]$gitVersionConfig = "")

    New-GitBranch "${prefix}release/$version/main"

    # To ensure that any commits on a 'fix' branch, for the first release on a release branch, get the correct
    # version number generated, this tag is required at the root of the release branch. 
    # Otherwise the major.minor.path is not right; this is because there is no reliable way for GitVersion to determine
    # major.minor.patch - it can't reliably determine it from the graph.
    # Incidently, you see this same situation occur with GitFlow, for the feature branches taken off the first ever release branch.
    # Though with Gitflow this never occurs with subsequent release branches because there's merge commits in the graph that
    # act as 'version anchors'.

    # This solution feels like an acceptable workaround considering the simplicitly of the branching model overall.
    New-GitTag "${tagprefix}/${version}.0-rc.0"
}

# Synopsis: Perform release hardening changes via 'fix' branches on a release branch
function Invoke-ReleaseFixWork {
    param(
        [string]$fixName,
        [string]$version,
        [string]$prefix = "",
        [string]$gitVersionConfig = "")

    New-GitBranch "${prefix}release/$version/fix/$fixName" -SourceBranch "${prefix}release/$version/main"
    Add-GitCommit ./info.txt -Message "$fixName - changes - 1" -GitVersionConfig $gitVersionConfig
    Add-GitCommit ./info.txt -Message "$fixName - changes - 2" -GitVersionConfig $gitVersionConfig
    New-GitMerge -TargetBranch "${prefix}release/$version/main" -GitVersionConfig $gitVersionConfig
}

# Synopsis: Perform the release for the current commit on the release branch
function Invoke-PerformRelease {
    param(
        [string]$version,
        [string]$prefix = "",
        [string]$tagprefix = "c",
        [string]$gitVersionConfig = "")

    New-GitTag "${tagprefix}/$((Invoke-GitVersion $gitVersionConfig).MajorMinorPatch)" -SourceBranch "${prefix}release/$version/main"
}