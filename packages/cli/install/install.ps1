$ErrorActionPreference = "Stop"

$Repo = "infinitedim/justui"
$BinaryName = "justui.exe"
$InstallDir = if ($env:JUSTUI_INSTALL_DIR) { $env:JUSTUI_INSTALL_DIR } else { "$env:LOCALAPPDATA\justui\bin" }

$Arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq "Arm64") { "aarch64" } else { "x86_64" }
$Target = "$Arch-pc-windows-msvc"

$Version = if ($env:JUSTUI_VERSION) { $env:JUSTUI_VERSION } else {
    (Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest").tag_name
}

$Archive = "justui-$Target.zip"
$Url = "https://github.com/$Repo/releases/download/$Version/$Archive"

Write-Host "Installing JustUI CLI $Version for $Target..."

$Tmp = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
New-Item -ItemType Directory -Path $Tmp | Out-Null

try {
    Invoke-WebRequest $Url -OutFile "$Tmp\$Archive"
    Expand-Archive "$Tmp\$Archive" -DestinationPath $Tmp

    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Copy-Item "$Tmp\$BinaryName" "$InstallDir\$BinaryName" -Force

    Write-Host "✓ Installed to $InstallDir\$BinaryName"

    $CurrentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($CurrentPath -notlike "*$InstallDir*") {
        [System.Environment]::SetEnvironmentVariable("PATH", "$CurrentPath;$InstallDir", "User")
        Write-Host "  Added $InstallDir to PATH (restart terminal to apply)"
    }
} finally {
    Remove-Item -Recurse -Force $Tmp
}
