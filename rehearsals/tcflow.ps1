. $PSScriptRoot/tcflow-utils.ps1

Set-GitBranchName master develop
Add-GitCommit  ./info.txt "init" "init"

# vnext feature work on develop

Invoke-FeatureBranchWork "story_a" develop
Invoke-FeatureBranchWork "story_b" develop

# Start release hardening phase for 1.0.0

Invoke-InitReleaseBranch "1.0"
Invoke-ReleaseFixWork "m" "1.0"

# Concurrent dev work for vnext on develop

Invoke-FeatureBranchWork "story_c" develop

# More release hardening and then the release of 1.0.0

Invoke-ReleaseFixWork "n" "1.0"
Invoke-PerformRelease "1.0"

# More dev work on develop

Invoke-FeatureBranchWork "story_d" develop

# New 'Minor' release (1.1.0) hardening phase and release

Invoke-InitReleaseBranch "1.1"
Invoke-ReleaseFixWork "o" "1.1"
Invoke-PerformRelease "1.1"

# More dev work on develop

Invoke-FeatureBranchWork "story_e" develop

# Patch/hotfix release release for 1.0 (1.0.1)
Invoke-ReleaseFixWork "p" "1.0"
Invoke-PerformRelease "1.0"

# New major release, with no hardening required

Invoke-InitReleaseBranch "2.0"
Invoke-PerformRelease "2.0"
