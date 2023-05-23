Add-GitCommit  ./info.txt "init" "init"

New-GitBranch develop

$branch_a = "feature/story_a"
New-GitBranch $branch_a
Add-GitCommit ./info.txt -Message "$branch_a - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_a - changes - 2"

New-GitMerge -TargetBranch develop

$branch_pinx = "feature/schema-pin_x"
New-GitBranch $branch_pinx

$branch_pinx_i = "$branch_pinx-story_i"
New-GitBranch $branch_pinx_i
Add-GitCommit ./info-2.txt -Message "$branch_pinx_i - changes - 1"
Add-GitCommit ./info-2.txt -Message "$branch_pinx_i - changes - 2"
New-GitMerge -TargetBranch $branch_pinx

$branch_pinx_j = "$branch_pinx-story_j"
New-GitBranch $branch_pinx_j
Add-GitCommit ./info-2.txt -Message "$branch_pinx_j - changes - 1"
Add-GitCommit ./info-2.txt -Message "$branch_pinx_j - changes - 2"
New-GitMerge -TargetBranch $branch_pinx

git checkout develop
$branch_b = "feature/story_b"
New-GitBranch $branch_b
Add-GitCommit ./info.txt -Message "$branch_b - changes - 1"
Add-GitCommit ./info.txt -Message "$branch_b - changes - 2"
New-GitMerge -TargetBranch develop

New-GitMerge -SourceBranch $branch_pinx -TargetBranch develop -DeleteSource