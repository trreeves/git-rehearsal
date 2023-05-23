Add-GitCommit  ./info.txt "init" "init"

New-GitBranch develop

$branch_a = "feature/milestone1_story_a"
New-GitBranch $branch_a
Add-GitCommit ./info.txt -Message "$branch_a - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_a - changes - 2"

New-GitMerge -TargetBranch develop 

$branch_b = "feature/milestone1_story_b"
New-GitBranch $branch_b
Add-GitCommit ./info.txt -Message "$branch_b - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_b - changes - 2"

New-GitMerge -TargetBranch develop 

$release_0_2_0 = "release/0.2.0"
New-GitBranch $release_0_2_0
Add-GitCommit ./info.txt -Message "$release_0_2_0 - milestone 1 - hardening - 1"
Add-GitCommit ./info.txt -Message "$release_0_2_0 - milestone 1 - hardening - 2"

New-GitMerge -SourceBranch $release_0_2_0 -TargetBranch master
New-GitMerge -SourceBranch $release_0_2_0 -TargetBranch develop 

# ------------------

$branch_c = "feature/milestone2_story_c"
New-GitBranch $branch_c
Add-GitCommit ./info.txt -Message "$branch_c - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_c - changes - 2"

New-GitMerge -TargetBranch develop 

$branch_d = "feature/milestone2_story_d"
New-GitBranch $branch_d
Add-GitCommit ./info.txt -Message "$branch_d - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_d - changes - 2"

New-GitMerge -TargetBranch develop 

$release_0_3_0 = "release/0.3.0"
New-GitBranch $release_0_3_0
Add-GitCommit ./info.txt -Message "$release_0_3_0 - milestone 2 - hardening - 1"
Add-GitCommit ./info.txt -Message "$release_0_3_0 - milestone 2 - hardening - 2"

New-GitMerge -SourceBranch $release_0_3_0 -TargetBranch master
New-GitMerge -SourceBranch $release_0_3_0 -TargetBranch develop