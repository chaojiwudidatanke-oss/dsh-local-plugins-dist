# DSH 本地插件同步包（加密分发）

这个仓库只放**分发引导**与**加密安装包**：包用 AES-256 加密（PBKDF2 + HMAC-SHA256 防篡改），密码单独告知。
仓库里没有明文包；明文源码在私有仓库 chaojiwudidatanke-oss/dsh-local-plugins。

## 一键安装（在那台电脑的 PowerShell 里粘贴一行）

    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol='Tls12'; iwr 'https://github.com/chaojiwudidatanke-oss/dsh-local-plugins-dist/releases/download/v4d801983ea7b/install-from-url.ps1' -OutFile $env:TEMP\i.ps1; & $env:TEMP\i.ps1 -Url 'https://github.com/chaojiwudidatanke-oss/dsh-local-plugins-dist/releases/download/v4d801983ea7b/pack-4d801983ea7b.aes'"

执行后会提示输入密码，然后自动：下载 → 校验 → 解密 → 解压 → 运行 install.cmd。
安装前请完全退出 DSH（含托盘）。装完重开 DSH，再跑安装目录里的 check.cmd 自检（约 2 分钟，逐项打印）。

## 手动方式

1. 在 Releases 下载 pack-4d801983ea7b.aes 和 install-from-url.ps1；
2. powershell -NoProfile -ExecutionPolicy Bypass -File install-from-url.ps1 -Path <pack.aes 路径>，输入密码。

## 说明

- 版本号 = 包内容 hash（4d801983ea7b）；包内已排除体积过大的技能。
- 更新：开发机重新构建 → encrypt-pack.mjs 加密 → 本仓库发新 Release（脚本与包同版本）。
- 加密包 SHA256：212AA49B15B8D8D8003CB160C27084F04765D85DCF5965CB8E921E5FB1EFF8E5（可作 -Sha256 传给脚本做完整性校验）。