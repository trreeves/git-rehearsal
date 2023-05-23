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

Set-GitBranchName master develop
Add-GitCommit  ./info.txt "init" "init"

# vnext feature work on develop

$branch_a = "feature/story_a"
New-GitBranch $branch_a
    Add-GitCommit ./info.txt -Message "$branch_a - changes - 1"
    Add-GitCommit ./info.txt -Message "$branch_a - changes - 2"
    New-GitMerge -TargetBranch develop

$branch_b = "feature/story_b"
New-GitBranch $branch_b
    Add-GitCommit ./info1.txt -Message "$branch_b - changes - 1"
    Add-GitCommit ./info1.txt -Message "$branch_b - changes - 2"
    New-GitMerge -TargetBranch develop

# Start release hardening phase for 1.0.0

$release_1_0 = "release/1.0"
New-GitBranch "$release_1_0/main"
    New-GitTag "rc/v$((Invoke-GitVersion).FullSemVer)"
    New-GitBranch "$release_1_0/fix/m" 
        Add-GitCommit ./info1.txt -Message "release hardening m-1"
        Add-GitCommit ./info1.txt -Message "release hardening m-2"
        New-GitMerge -TargetBranch "$release_1_0/main"

# Concurrent dev work for vnext on develop

$branch_c = "feature/story_c"
New-GitBranch $branch_c -SourceBranch develop
    Add-GitCommit ./info1.txt -Message "$branch_c - changes - 1"
    Add-GitCommit ./info1.txt -Message "$branch_c - changes - 2"
    New-GitMerge -TargetBranch develop

# More release hardening and then the release of 1.0.0

New-GitBranch "$release_1_0/fix/n" -SourceBranch $release_1_0/main
    Add-GitCommit ./info1.txt -Message "release hardening n-1"
    Add-GitCommit ./info1.txt -Message "release hardening n-2"
    New-GitMerge -TargetBranch "$release_1_0/main"

    ## release
    New-GitTag "v$((Invoke-GitVersion).MajorMinorPatch)"

# More dev work on develop

$branch_d = "feature/story_d"
New-GitBranch $branch_d -SourceBranch develop
    Add-GitCommit ./info1.txt -Message "$branch_d - changes"
    New-GitMerge -TargetBranch develop

# New 'Minor' release (1.1.0) hardening phase and release

$release_1_1 = "release/1.1"
New-GitBranch "$release_1_1/main"
    New-GitTag "rc/v$((Invoke-GitVersion).FullSemVer)"
    New-GitBranch "$release_1_1/fix/o" -SourceBranch $release_1_1/main
        Add-GitCommit ./info1.txt -Message "release hardening o-1"
        Add-GitCommit ./info1.txt -Message "release hardening o-2"
        New-GitMerge -TargetBranch "$release_1_1/main"

        ## release
        New-GitTag "v$((Invoke-GitVersion).MajorMinorPatch)"

# More dev work on develop

$branch_e = "feature/story_e"
New-GitBranch $branch_e -SourceBranch develop
    Add-GitCommit ./info1.txt -Message "$branch_e - changes"
    New-GitMerge -TargetBranch develop

# Patch/hotfix release release for 1.0 (1.0.1)

New-GitBranch "$release_1_0/fix/p" -SourceBranch $release_1_0/main
    Add-GitCommit ./info1.txt -Message "release hardening p-1"
    Add-GitCommit ./info1.txt -Message "release hardening p-2"
    New-GitMerge -TargetBranch "$release_1_0/main"
    New-GitTag "v$((Invoke-GitVersion).MajorMinorPatch)"

# New major release, with no hardening required

$release_2_0 = "release/2.0"
New-GitBranch "$release_2_0/main" -SourceBranch develop
    New-GitTag "rc/v$((Invoke-GitVersion).FullSemVer)"

    ## release
    New-GitTag "v$((Invoke-GitVersion).MajorMinorPatch)"