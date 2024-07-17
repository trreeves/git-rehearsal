. $PSScriptRoot/tcflow-utils.ps1

$forkedConfig = "tcflow-forked-component-c-delivery-gitversion.yml"
$c1Config = "tcflow-gitversion-c1.yml"

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

# New 'Minor' release (1.1.0) hardening phase and release

Invoke-FeatureBranchWork "story_e" develop -GitVersionConfig $c1Config
New-GitTag "c1/$((Invoke-GitVersion $c1Config).MajorMinorPatch)"

Invoke-FeatureBranchWork "story_f" develop -GitVersionConfig $c1Config
New-GitTag "c1/$((Invoke-GitVersion $c1Config).MajorMinorPatch)"

# More dev work on develop
Invoke-FeatureBranchWork "story_g" develop
Invoke-InitReleaseBranch "2.0"

Invoke-FeatureBranchWork "story_h" develop -GitVersionConfig $c1Config
New-GitTag "c1/$((Invoke-GitVersion $c1Config).MajorMinorPatch)"