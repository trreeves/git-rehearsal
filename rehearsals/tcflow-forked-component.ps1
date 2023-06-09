. $PSScriptRoot/tcflow-utils.ps1

$forkedConfig = "tcflow-forked-component-c-delivery-gitversion.yml"

Set-GitBranchName master "develop"
Add-GitCommit -File ./info.txt -Value "init" -Message "init"

# vnext feature work on develop

Invoke-FeatureBranchWork "story_a" "develop"
Invoke-FeatureBranchWork "story_b" "develop"

# Start release hardening phase for 1.0.0

Invoke-InitReleaseBranch "1.0"
Invoke-ReleaseFixWork "m" "1.0"

# Start a forked version, within the same repo
New-GitBranch "fk/develop" -SourceBranch develop
New-GitTag "fk/5.0.0-alpha.0" "fk/develop"

# Concurrent dev work for vnext on fork
Invoke-FeatureBranchWork "story_c" "fk/develop" -Prefix "fk/" -GitVersionConfig $forkedConfig

# More release hardening and then the release of 1.0.0

Invoke-ReleaseFixWork "n" "1.0"
Invoke-PerformRelease "1.0"

Invoke-FeatureBranchWork "fk_story_j" fk/develop -Prefix "fk/" -GitVersionConfig $forkedConfig
Invoke-FeatureBranchWork "fk_story_k" fk/develop -Prefix "fk/" -GitVersionConfig $forkedConfig
Invoke-InitReleaseBranch "5.0" -Prefix "fk/" -TagPrefix "fk" -GitVersionConfig $forkedConfig
Invoke-ReleaseFixWork "l" "5.0" -Prefix "fk/" -GitVersionConfig $forkedConfig
Invoke-PerformRelease "5.0" -Prefix "fk/" -TagPrefix "fk" -GitVersionConfig $forkedConfig

# More dev work on develop

Invoke-FeatureBranchWork "story_d" develop

exit

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
