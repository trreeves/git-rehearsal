Add-GitCommit  ./info.txt "init" "init"

New-GitBranch develop

$branch_a = "feature/story_a"
New-GitBranch $branch_a
Add-GitCommit ./info.txt "$branch_a - 1" "$branch_a - changes - 1"
Add-GitCommit ./info.txt "$branch_a - 2" "$branch_a - changes - 2"
New-GitMerge -TargetBranch develop

$release_0_2_0 = "release/0.2.0"
New-GitBranch $release_0_2_0
Add-GitCommit ./info.txt "$release_0_2_0 - 1" "$release_0_2_0 - prep - 1"

git checkout develop

$branch_b = "feature/story_b"
New-GitBranch $branch_b
Add-GitCommit ./info-2.txt "$branch_b" "$branch_b - changes"
New-GitMerge -TargetBranch develop

git checkout $release_0_2_0
Add-GitCommit ./info.txt "$release_0_2_0 - 2" "$release_0_2_0 - prep - 2"

New-GitMerge -SourceBranch $release_0_2_0 -TargetBranch master
New-GitMerge -SourceBranch $release_0_2_0 -TargetBranch develop