Add-GitCommit  ./info.txt "init" "init"
New-GitBranch develop

# First release - simple

$branch_a = "feature/story_a"
New-GitBranch $branch_a
Add-GitCommit ./info.txt -Message "$branch_a - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_a - changes - 2"
New-GitMerge -TargetBranch develop

$release_1_0_0 = "release/1.0.0"
New-GitBranch $release_1_0_0
Add-GitCommit ./info1.txt -Message "$release_1_0_0 - init" # GitVersion doesn't detect the correct 'parent' branch without an initial direct commit on release branches

$branch_b = "feature/story_b"
New-GitBranch $branch_b
Add-GitCommit ./info1.txt -Message "$branch_b - changes - 1"
Add-GitCommit ./info1.txt -Message "$branch_b - changes - 2"
New-GitMerge -TargetBranch $release_1_0_0

New-GitMerge -SourceBranch $release_1_0_0 -TargetBranch master
New-GitMerge -SourceBranch $release_1_0_0 -TargetBranch develop

# vNext development

git checkout develop

$branch_c = "feature/story_c"
New-GitBranch $branch_c
Add-GitCommit ./info.txt -Message "$branch_c - changes +semver:minor"
New-GitMerge -TargetBranch develop

# second release with hardening

$release_1_1_0 = "release/1.1.0"
New-GitBranch $release_1_1_0
Add-GitCommit ./info2.txt -Message "$release_1_1_0 - init" # GitVersion doesn't detect the correct 'parent' branch without an initial direct commit on release branches

$branch_d = "feature/story_d"
New-GitBranch $branch_d
Add-GitCommit ./info2.txt -Message "$branch_d - changes - 1"
Add-GitCommit ./info2.txt -Message "$branch_d - changes - 2"
New-GitMerge -TargetBranch $release_1_1_0

$branch_e = "feature/story_e"
New-GitBranch $branch_e
Add-GitCommit ./info2.txt -Message "$branch_e - changes - 1"
Add-GitCommit ./info2.txt -Message "$branch_e - changes - 2"
New-GitMerge -TargetBranch $release_1_1_0

# Ongoing work for vNext

git checkout develop

$branch_f = "feature/story_f"
New-GitBranch $branch_f
Add-GitCommit ./info.txt -Message "$branch_f - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_f - changes - 2"
New-GitMerge -TargetBranch develop

# Perform second release
New-GitMerge -SourceBranch $release_1_1_0 -TargetBranch master
New-GitMerge -SourceBranch $release_1_1_0 -TargetBranch develop

