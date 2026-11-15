<#
.SYNOPSIS
  Builds pcsc-rs for OpenWrt 18.06 (mipsel_24kc) from Windows, through WSL.
.EXAMPLE
  .\scripts\build-mipsel.ps1
  .\scripts\build-mipsel.ps1 -Distro Lavuntu -Nightly nightly-2026-09-28
#>
param(
    [string]$Distro = "Lavuntu",
    [string]$Sdk = "/home/shinano/openwrt-sdk",
    [string]$Unwind = "/home/shinano/openwrt-unwind",
    [string]$Compat = "/home/shinano/openwrt-compat.o",
    [string]$CargoBin = "/home/shinano/.cargo-lavuntu/bin",
    [string]$Nightly = "nightly-2026-09-28"
)

$ErrorActionPreference = "Stop"

# This repository, as WSL sees it (C:\a\b -> /mnt/c/a/b)
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$wslRepo = "/mnt/" + $repo.Substring(0, 1).ToLower() + $repo.Substring(2).Replace('\', '/')

# A clean PATH on purpose: WSL would otherwise add the Windows PATH (spaces, .exe tools)
$command = @"
set -eu
cd '$wslRepo'
export PATH='$CargoBin':/usr/bin:/bin
export OPENWRT_SDK='$Sdk'
export OPENWRT_UNWIND='$Unwind'
export OPENWRT_COMPAT='$Compat'
export NIGHTLY='$Nightly'
sh scripts/build-openwrt-mipsel.sh
"@
# bash -c gets LF line endings only
$command = $command -replace "`r`n", "`n"

Write-Host "WSL ($Distro): $wslRepo"
wsl -d $Distro -- bash -lc $command
if ($LASTEXITCODE -ne 0) {
    throw "the build failed (exit code $LASTEXITCODE)"
}

$out = Join-Path $repo "pcsc-rs-mipsel-unknown-linux-musl"
if (Test-Path $out) {
    $size = [math]::Round((Get-Item $out).Length / 1MB, 2)
    Write-Host "Built: $out ($size MB)"
} else {
    throw "the build finished, but $out was not created"
}
