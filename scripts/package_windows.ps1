$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$appSlug = if ($env:APP_SLUG) { $env:APP_SLUG } else { "pokrov" }
$repoRoot = (Get-Location).Path
$distDir = Join-Path $repoRoot "dist"
$outDir = Join-Path $repoRoot "out"
$portableStageDir = Join-Path $distDir "tmp\$appSlug"
$releaseRunnerDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
$runnerExePath = Join-Path $releaseRunnerDir "POKROV.exe"
$msixConfigPath = Join-Path $repoRoot "windows\packaging\msix\make_config.yaml"
$exeConfigPath = Join-Path $repoRoot "windows\packaging\exe\make_config.yaml"
$brandingSourceIcon = Join-Path $repoRoot "windows\branding\app_icon_source.ico"
$brandingSyncScript = Join-Path $repoRoot "windows\sync_branding_assets.py"
$brandingAppIcon = Join-Path $repoRoot "windows\runner\resources\app_icon.ico"
$builtMsixPath = Join-Path $releaseRunnerDir "$appSlug-windows-setup-x64.msix"
$canonicalExe = Join-Path $outDir "$appSlug-windows-setup-x64.exe"
$canonicalMsix = Join-Path $outDir "$appSlug-windows-setup-x64.msix"
$canonicalPortable = Join-Path $outDir "$appSlug-windows-portable-x64.zip"
$exeFirstMode = $env:PACKAGE_WINDOWS_EXE_FIRST -eq "1"

function Assert-CanonicalConfig {
    $msixConfig = Get-Content -Path $msixConfigPath -Raw
    $exeConfig = Get-Content -Path $exeConfigPath -Raw
    $publisherUrlMatch = [regex]::Match($exeConfig, 'publisher_url:\s*(\S+)')

    if ($msixConfig -match 'certificate_password:\s*portalvpn-dev') {
        throw "windows/packaging/msix/make_config.yaml still contains the legacy dev signing password."
    }

    if (-not $publisherUrlMatch.Success) {
        throw "windows/packaging/exe/make_config.yaml is missing publisher_url."
    }

    try {
        $publisherUri = [Uri]$publisherUrlMatch.Groups[1].Value.Trim()
    } catch {
        throw "windows/packaging/exe/make_config.yaml publisher_url is not a valid URI."
    }

    if (-not $publisherUri.IsAbsoluteUri -or $publisherUri.Scheme -ne 'https') {
        throw "windows/packaging/exe/make_config.yaml publisher_url must be an absolute HTTPS URL."
    }

    if ($exeConfig -match 'publisher_url:\s*https://github\.com/') {
        throw "windows/packaging/exe/make_config.yaml must use the canonical public publisher URL before packaging."
    }

    if ($msixConfig -match 'CN=POKROV VPN') {
        throw "windows/packaging/msix/make_config.yaml still contains the legacy public publisher CN."
    }

    if ($msixConfig -match 'Hiddify' -or $exeConfig -match 'Hiddify') {
        throw "Windows packaging config still contains legacy Hiddify branding."
    }

    if ($msixConfig -notmatch 'protocol_activation:\s*.*pokrov' -or
        $msixConfig -notmatch 'protocol_activation:\s*.*pokrovvpn') {
        throw "windows/packaging/msix/make_config.yaml must register both pokrov and pokrovvpn protocols."
    }
}

function Find-Artifact([string[]]$patterns, [string]$description) {
    $candidate = Get-ChildItem -Recurse -File -Path $distDir |
        Where-Object {
            foreach ($pattern in $patterns) {
                if ($_.Name -like $pattern) {
                    return $true
                }
            }
            return $false
        } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $candidate) {
        throw "Unable to find $description artifact in dist matching '$($patterns -join "', '")'."
    }

    return $candidate
}

function Sync-WindowsBrandingAssets {
    $pythonCommand = Get-Command python -ErrorAction Stop
    & $pythonCommand.Source $brandingSyncScript
    if ($LASTEXITCODE -ne 0) {
        throw "Windows branding asset sync failed."
    }
}

function Assert-ArtifactIsFresh([string]$artifactPath, [string]$description, [datetime]$referenceTimestampUtc) {
    if (-not (Test-Path $artifactPath)) {
        throw "$description artifact not found at $artifactPath"
    }

    $artifactTimestampUtc = (Get-Item $artifactPath).LastWriteTimeUtc
    if ($artifactTimestampUtc -lt $referenceTimestampUtc) {
        throw "$description artifact at $artifactPath is older than the refreshed Windows icon. Re-run the Windows release build before packaging."
    }
}

function Copy-MsixArtifactIfAvailable([datetime]$referenceTimestampUtc) {
    if ($exeFirstMode) {
        Write-Warning "PACKAGE_WINDOWS_EXE_FIRST=1 is enabled; canonical MSIX output is deferred for this local packaging run."
        return $false
    }

    if (Test-Path $builtMsixPath) {
        Assert-ArtifactIsFresh -artifactPath $builtMsixPath -description "Windows MSIX" -referenceTimestampUtc $referenceTimestampUtc
        Copy-Item $builtMsixPath -Destination $canonicalMsix -Force
        return $true
    }

    $releaseMsixCandidate = Get-ChildItem -Path $releaseRunnerDir -Filter "*.msix" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($releaseMsixCandidate) {
        Assert-ArtifactIsFresh -artifactPath $releaseMsixCandidate.FullName -description "Windows MSIX" -referenceTimestampUtc $referenceTimestampUtc
        Copy-Item $releaseMsixCandidate.FullName -Destination $canonicalMsix -Force
        return $true
    }

    try {
        $msixCandidate = Find-Artifact -patterns @("*.msix") -description "Windows MSIX"
        Assert-ArtifactIsFresh -artifactPath $msixCandidate.FullName -description "Windows MSIX" -referenceTimestampUtc $referenceTimestampUtc
        Copy-Item $msixCandidate.FullName -Destination $canonicalMsix -Force
        return $true
    } catch {
        if (-not $exeFirstMode) {
            throw
        }

        throw
    }
}

function Write-InstallHelpShortcut([string]$stageDir) {
    $shortcutPath = Join-Path $stageDir "POKROV Install Help.url"
    @"
[InternetShortcut]
URL=https://pokrov.space/install/
"@ | Set-Content -Path $shortcutPath -Encoding ASCII
}

Assert-CanonicalConfig
Sync-WindowsBrandingAssets

$brandingReferenceUtc = (Get-Item $brandingSourceIcon).LastWriteTimeUtc

New-Item -ItemType Directory -Force -Path (Join-Path $distDir "tmp") | Out-Null
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

if (Test-Path $portableStageDir) {
    Remove-Item -Path $portableStageDir -Recurse -Force
}

foreach ($artifact in @($canonicalExe, $canonicalMsix, $canonicalPortable)) {
    if (Test-Path $artifact) {
        Remove-Item -Path $artifact -Force
    }
}

$setupCandidate = Find-Artifact -patterns @("*pokrov*setup*.exe", "*hiddify*setup*.exe") -description "Windows setup"
Assert-ArtifactIsFresh -artifactPath $setupCandidate.FullName -description "Windows setup" -referenceTimestampUtc $brandingReferenceUtc
Copy-Item $setupCandidate.FullName -Destination $canonicalExe -Force

$hasMsix = Copy-MsixArtifactIfAvailable -referenceTimestampUtc $brandingReferenceUtc

if ($hasMsix) {
    $msixInspectDir = Join-Path $distDir "tmp\msix-inspect"
    $msixZipPath = Join-Path $distDir "tmp\msix-inspect.zip"
    if (Test-Path $msixInspectDir) {
        Remove-Item -Path $msixInspectDir -Recurse -Force
    }
    if (Test-Path $msixZipPath) {
        Remove-Item -Path $msixZipPath -Force
    }
    Copy-Item $canonicalMsix -Destination $msixZipPath -Force
    Expand-Archive -Path $msixZipPath -DestinationPath $msixInspectDir -Force
    $manifestPath = Join-Path $msixInspectDir "AppxManifest.xml"
    if (-not (Test-Path $manifestPath)) {
        throw "Packaged MSIX is missing AppxManifest.xml"
    }
    $manifestText = Get-Content -Path $manifestPath -Raw
    $requiredManifestPatterns = @(
        '<uap:Protocol Name="pokrov"',
        '<uap:Protocol Name="pokrovvpn"'
    )
    foreach ($pattern in $requiredManifestPatterns) {
        if ($manifestText -notmatch $pattern) {
            throw "Packaged MSIX is missing required protocol registration: $pattern"
        }
    }
    $publicResiduePatterns = @(
        '<DisplayName>[^<]*VPN[^<]*</DisplayName>',
        '<PublisherDisplayName>[^<]*VPN[^<]*</PublisherDisplayName>',
        '<Description>[^<]*VPN[^<]*</Description>',
        '<uap:DefaultTile ShortName="[^"]*VPN[^"]*"',
        '<DisplayName>[^<]*Hiddify[^<]*</DisplayName>',
        '<PublisherDisplayName>[^<]*Hiddify[^<]*</PublisherDisplayName>',
        '<Description>[^<]*Hiddify[^<]*</Description>',
        '<uap:DefaultTile ShortName="[^"]*Hiddify[^"]*"',
        '<uap:Protocol Name="hiddify"',
        '<uap:Protocol Name="v2ray"',
        '<uap:Protocol Name="v2rayn"',
        '<uap:Protocol Name="v2rayng"',
        '<uap:Protocol Name="clash"',
        '<uap:Protocol Name="clashmeta"',
        '<uap:Protocol Name="sing-box"'
    )
    if ($publicResiduePatterns | Where-Object { $manifestText -match $_ }) {
        throw "Legacy public Windows residue detected in MSIX manifest."
    }
    Remove-Item -Path $msixInspectDir -Recurse -Force
    Remove-Item -Path $msixZipPath -Force
}

if (-not (Test-Path $releaseRunnerDir)) {
    throw "Windows runner release directory not found at $releaseRunnerDir"
}
Assert-ArtifactIsFresh -artifactPath $runnerExePath -description "Windows runner executable" -referenceTimestampUtc $brandingReferenceUtc
Assert-ArtifactIsFresh -artifactPath $brandingAppIcon -description "Windows app icon" -referenceTimestampUtc $brandingReferenceUtc

xcopy $releaseRunnerDir $portableStageDir /E /H /C /I /Y | Out-Null
Write-InstallHelpShortcut -stageDir $portableStageDir
Get-ChildItem -Path $portableStageDir -Filter "*.msix" -File -Recurse -ErrorAction SilentlyContinue |
    Remove-Item -Force

$allowedInternalResiduePatterns = @(
    'hiddify-core.dll'
)
$legacyResidue = Get-ChildItem -Path $portableStageDir -Recurse -File |
    Where-Object {
        ($_.Name -like "*Hiddify*" -or $_.Name -like "*POKROVVPN*") -and
        ($allowedInternalResiduePatterns -notcontains $_.Name)
    }

if ($legacyResidue) {
    $legacyNames = $legacyResidue | ForEach-Object { $_.FullName }
    throw "Legacy Windows residue detected in portable package:`n$($legacyNames -join "`n")"
}

Compress-Archive -Force -Path $portableStageDir -DestinationPath $canonicalPortable

Write-Host "Windows packaging artifacts ready:"
Get-ChildItem -Path $outDir -File | Select-Object Name, Length
