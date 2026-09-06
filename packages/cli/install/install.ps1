$ErrorActionPreference = "Stop"

# Ensure TLS 1.2 is enabled for older PowerShell / .NET Framework versions
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$Repo = if ($env:JUSTUI_REPO) { $env:JUSTUI_REPO } else { "infinitedim/justui" }
$BinaryName = "justui.exe"
$InstallDir = if ($env:JUSTUI_INSTALL_DIR) { $env:JUSTUI_INSTALL_DIR } else { "$env:LOCALAPPDATA\justui\bin" }

$Arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq "Arm64") { "aarch64" } else { "x86_64" }
$Target = "$Arch-pc-windows-msvc"

$Version = if ($env:JUSTUI_VERSION) { $env:JUSTUI_VERSION } else {
    $resolvedVersion = $null

    # 1. Primary: HttpWebRequest 302 redirect resolution (no API rate limit)
    try {
        $req = [System.Net.HttpWebRequest]::Create("https://github.com/$Repo/releases/latest")
        $req.AllowAutoRedirect = $false
        $req.Method = "HEAD"
        $req.UserAgent = "justui-cli"
        $resp = $req.GetResponse()
        $loc = $resp.GetResponseHeader("Location")
        $resp.Close()
        if ($loc -and $loc -match "/tag/([^/?#]+)") {
            $resolvedVersion = $matches[1]
        } elseif ($loc -and $loc.Contains('/')) {
            $resolvedVersion = $loc.Substring($loc.LastIndexOf('/') + 1).Trim().Trim('/')
        }
    } catch {
        try {
            $req = [System.Net.HttpWebRequest]::Create("https://github.com/$Repo/releases/latest")
            $req.AllowAutoRedirect = $false
            $req.Method = "GET"
            $req.UserAgent = "justui-cli"
            $resp = $req.GetResponse()
            $loc = $resp.GetResponseHeader("Location")
            $resp.Close()
            if ($loc -and $loc -match "/tag/([^/?#]+)") {
                $resolvedVersion = $matches[1]
            } elseif ($loc -and $loc.Contains('/')) {
                $resolvedVersion = $loc.Substring($loc.LastIndexOf('/') + 1).Trim().Trim('/')
            }
        } catch {
            # Fall through to API strategies
        }
    }

    # 2. Fallback: Authenticated API if GITHUB_TOKEN is set
    if (-not $resolvedVersion -and $env:GITHUB_TOKEN) {
        try {
            $headers = @{
                "Authorization" = "Bearer $env:GITHUB_TOKEN"
                "User-Agent" = "justui-cli"
            }
            $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $headers
            $resolvedVersion = $rel.tag_name
        } catch {
            # Fall through
        }
    }

    # 3. Last resort: Unauthenticated API
    if (-not $resolvedVersion) {
        try {
            $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers @{ "User-Agent" = "justui-cli" }
            $resolvedVersion = $rel.tag_name
        } catch {
            # Fall through
        }
    }

    $resolvedVersion
}

if ([string]::IsNullOrWhiteSpace($Version) -or $Version -eq "latest") {
    throw "Error: Could not determine latest version for $Repo. Please specify version manually via `$env:JUSTUI_VERSION = 'vX.Y.Z'"
}

if (-not $Version.StartsWith("v")) {
    $Version = "v$Version"
}

$Archive = "justui-$Target.zip"
$Url = "https://github.com/$Repo/releases/download/$Version/$Archive"

Write-Host "Installing JustUI CLI $Version for $Target..."

$Tmp = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
New-Item -ItemType Directory -Path $Tmp | Out-Null

try {
    Invoke-WebRequest -Uri $Url -OutFile "$Tmp\$Archive" -UseBasicParsing
    Expand-Archive "$Tmp\$Archive" -DestinationPath $Tmp

    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Copy-Item "$Tmp\$BinaryName" "$InstallDir\$BinaryName" -Force

    Write-Host "✓ Installed to $InstallDir\$BinaryName"

    $CurrentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($CurrentPath -notlike "*$InstallDir*") {
        $NewPath = if ($CurrentPath) { "$CurrentPath;$InstallDir" } else { $InstallDir }
        [System.Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
        Write-Host "  Added $InstallDir to PATH (restart terminal to apply)"
    }
} finally {
    Remove-Item -Recurse -Force $Tmp
}
