# 从 URL 一键安装同步包
# 用法（在那台电脑的 PowerShell 里粘贴一行即可）：
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr '<本脚本直链>' -OutFile $env:TEMP\i.ps1; & $env:TEMP\i.ps1 -Url '<加密包直链>'"
# 会在安装前询问密码；安装完成后会提示重启 DSH。
param(
  [string]$Url,
  [string]$Path,
  [string]$Password,
  [string]$Sha256,
  [switch]$ExtractOnly
)
$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 defaults to TLS 1.0; GitHub requires 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Stop-With([string]$Message) {
  Write-Host "安装失败：$Message" -ForegroundColor Red
  exit 1
}

if (-not $Path -and -not $Url) { Stop-With '需要 -Url（加密包直链）或 -Path（本地加密包）' }
if (-not $Password) {
  $secure = Read-Host -AsSecureString '同步包密码'
  $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { $Password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

$work = Join-Path $env:TEMP ("dsh-sync-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
try {
  $encrypted = Join-Path $work 'pack.aes'
  if ($Path) {
    Copy-Item -LiteralPath $Path -Destination $encrypted
  } else {
    Write-Host "下载中…… $Url"
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $encrypted
  }

  if ($Sha256) {
    $actual = (Get-FileHash -LiteralPath $encrypted -Algorithm SHA256).Hash
    if ($actual -ne $Sha256.ToUpperInvariant()) { Stop-With "校验失败（SHA256 不符）：$actual" }
  }

  Write-Host '解密中……'
  $bytes = [IO.File]::ReadAllBytes($encrypted)
  if ($bytes.Length -lt (6 + 16 + 16 + 32)) { Stop-With '加密包太小或已损坏' }
  $magic = [Text.Encoding]::ASCII.GetString($bytes, 0, 6)
  if ($magic -ne 'DSHPK1') { Stop-With '不是同步包（magic 不符）' }

  $salt = New-Object byte[] 16
  [Array]::Copy($bytes, 6, $salt, 0, 16)
  $iv = New-Object byte[] 16
  [Array]::Copy($bytes, 22, $iv, 0, 16)
  $cipherLength = $bytes.Length - 38 - 32
  $cipher = New-Object byte[] $cipherLength
  [Array]::Copy($bytes, 38, $cipher, 0, $cipherLength)
  $mac = New-Object byte[] 32
  [Array]::Copy($bytes, $bytes.Length - 32, $mac, 0, 32)

  $kdf = New-Object Security.Cryptography.Rfc2898DeriveBytes($Password, $salt, 200000)
  $material = $kdf.GetBytes(64)
  $encryptKey = New-Object byte[] 32
  [Array]::Copy($material, 0, $encryptKey, 0, 32)
  $macKey = New-Object byte[] 32
  [Array]::Copy($material, 32, $macKey, 0, 32)

  $macInput = New-Object byte[] (16 + 16 + $cipherLength)
  [Array]::Copy($salt, 0, $macInput, 0, 16)
  [Array]::Copy($iv, 0, $macInput, 16, 16)
  [Array]::Copy($cipher, 0, $macInput, 32, $cipherLength)
  $hmac = New-Object Security.Cryptography.HMACSHA256
  $hmac.Key = $macKey
  $expected = $hmac.ComputeHash($macInput)
  $matchesMac = $true
  for ($index = 0; $index -lt 32; $index++) { if ($expected[$index] -ne $mac[$index]) { $matchesMac = $false } }
  if (-not $matchesMac) { Stop-With '密码错误，或加密包被改动过' }

  $aes = New-Object Security.Cryptography.AesCryptoServiceProvider
  $aes.Mode = 'CBC'
  $aes.Padding = 'PKCS7'
  $aes.Key = $encryptKey
  $aes.IV = $iv
  $decryptor = $aes.CreateDecryptor()
  $plain = $decryptor.TransformFinalBlock($cipher, 0, $cipherLength)

  $zip = Join-Path $work 'pack.zip'
  [IO.File]::WriteAllBytes($zip, $plain)
  $outDir = Join-Path $work 'pack'
  Expand-Archive -LiteralPath $zip -DestinationPath $outDir -Force

  if ($ExtractOnly) {
    Write-Host "已解压到：$outDir"
    return
  }

  $version = 'unknown'
  $versionFile = Join-Path $outDir 'VERSION.txt'
  if (Test-Path $versionFile) {
    $line = Select-String -LiteralPath $versionFile -Pattern '^pack=' | Select-Object -First 1
    if ($line) { $version = $line.Line.Split('=')[1] }
  }
  Write-Host "包版本：$version"
  Write-Host '开始安装（请确认 DSH 已完全退出）……'
  & (Join-Path $outDir 'install.cmd')
  $code = $LASTEXITCODE
  if ($code -ne 0) { Stop-With "安装器返回 $code" }
  Write-Host ''
  Write-Host '安装完成。下一步：重开 DSH，然后双击安装目录里的 check.cmd 自检。' -ForegroundColor Green
} catch {
  Stop-With $_.Exception.Message
}
