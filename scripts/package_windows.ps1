$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$appSlug = if ($env:APP_SLUG) { $env:APP_SLUG } else { "pokrov" }
$repoRoot = (Get-Location).Path
$distDir = Join-Path $repoRoot "dist"
$outDir = Join-Path $repoRoot "out"
$portableStageDir = Join-Path $distDir "tmp\$appSlug"
$releaseRunnerDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
$msixConfigPath = Join-Path $repoRoot "windows\packaging\msix\make_config.yaml"
$exeConfigPath = Join-Path $repoRoot "windows\packaging\exe\make_config.yaml"
$builtMsixPath = Join-Path $releaseRunnerDir "pokrov-windows-setup-x64.msix"
$canonicalExe = Join-Path $outDir "$appSlug-windows-setup-x64.exe"
$canonicalMsix = Join-Path $outDir "$appSlug-windows-setup-x64.msix"
$canonicalPortable = Join-Path $outDir "$appSlug-windows-portable-x64.zip"

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

    if ($msixConfig -match 'Hiddify' -or $exeConfig -match 'Hiddify') {
        throw "Windows packaging config still contains legacy Hiddify branding."
    }
}

function Find-Artifact([string]$pattern, [string]$description) {
    $candidate = Get-ChildItem -Recurse -File -Path $distDir |
        Where-Object { $_.Name -like $pattern } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $candidate) {
        throw "Unable to find $description artifact in dist matching '$pattern'."
    }

    return $candidate
}

Assert-CanonicalConfig

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

$setupCandidate = Find-Artifact -pattern "*pokrov*setup*.exe" -description "Windows setup"
Copy-Item $setupCandidate.FullName -Destination $canonicalExe -Force

if (Test-Path $builtMsixPath) {
    Copy-Item $builtMsixPath -Destination $canonicalMsix -Force
} else {
    $msixCandidate = Find-Artifact -pattern "*.msix" -description "Windows MSIX"
    Copy-Item $msixCandidate.FullName -Destination $canonicalMsix -Force
}

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
$publicResiduePatterns = @(
    '<DisplayName>[^<]*VPN[^<]*</DisplayName>',
    '<PublisherDisplayName>[^<]*VPN[^<]*</PublisherDisplayName>',
    '<Description>[^<]*VPN[^<]*</Description>',
    '<uap:DefaultTile ShortName="[^"]*VPN[^"]*"',
    '<uap:Protocol Name="pokrovvpn">',
    '<uap:DisplayName>pokrovvpn URI Scheme</uap:DisplayName>',
    '<DisplayName>[^<]*Hiddify[^<]*</DisplayName>',
    '<PublisherDisplayName>[^<]*Hiddify[^<]*</PublisherDisplayName>',
    '<Description>[^<]*Hiddify[^<]*</Description>',
    '<uap:DefaultTile ShortName="[^"]*Hiddify[^"]*"'
)
if ($publicResiduePatterns | Where-Object { $manifestText -match $_ }) {
    throw "Legacy public Windows residue detected in MSIX manifest."
}
Remove-Item -Path $msixInspectDir -Recurse -Force
Remove-Item -Path $msixZipPath -Force

if (-not (Test-Path $releaseRunnerDir)) {
    throw "Windows runner release directory not found at $releaseRunnerDir"
}

xcopy $releaseRunnerDir $portableStageDir /E /H /C /I /Y | Out-Null
xcopy ".github\help\mac-windows\*.url" $portableStageDir /E /H /C /I /Y | Out-Null

$legacyResidue = Get-ChildItem -Path $portableStageDir -Recurse -File |
    Where-Object {
        $_.Name -like "*Hiddify*"
    }

if ($legacyResidue) {
    $legacyNames = $legacyResidue | ForEach-Object { $_.FullName }
    throw "Legacy Windows residue detected in portable package:`n$($legacyNames -join "`n")"
}

Compress-Archive -Force -Path $portableStageDir -DestinationPath $canonicalPortable

Write-Host "Windows packaging artifacts ready:"
Get-ChildItem -Path $outDir -File | Select-Object Name, Length
