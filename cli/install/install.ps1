# Install the agnts CLI on Windows:
#   irm https://agnts.uz/install.ps1 | iex
# $env:AGNTS_VERSION picks a version (default: latest).
$ErrorActionPreference = 'Stop'

$base = if ($env:AGNTS_DOWNLOAD_URL) { $env:AGNTS_DOWNLOAD_URL } else { 'https://agnts.uz/cli' }
$version = if ($env:AGNTS_VERSION) { 'v' + $env:AGNTS_VERSION.TrimStart('v') } else { 'latest' }
$target = 'x86_64-pc-windows-msvc'
$url = "$base/$version/agnts-$target.zip"

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("agnts-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    Write-Host "Downloading agnts ($target)..."
    Invoke-WebRequest -UseBasicParsing $url -OutFile "$tmp\agnts.zip"
    $want = (Invoke-WebRequest -UseBasicParsing "$url.sha256").Content.ToString().Trim().Split(' ')[0]
    $got = (Get-FileHash "$tmp\agnts.zip" -Algorithm SHA256).Hash
    if ($want.ToLower() -ne $got.ToLower()) { throw 'checksum mismatch, not installing' }

    $dir = Join-Path $env:LOCALAPPDATA 'agnts\bin'
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Expand-Archive -Force "$tmp\agnts.zip" $dir

    $path = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not ($path -split ';' | Where-Object { $_ -eq $dir })) {
        [Environment]::SetEnvironmentVariable('Path', "$path;$dir", 'User')
        Write-Host "Added $dir to your PATH (open a new terminal to use it)."
    }
    & "$dir\agnts.exe" --version
    Write-Host ''
    Write-Host 'Next: agnts install root@your-server --domain agnts.example.com'
}
finally {
    Remove-Item -Recurse -Force $tmp
}
