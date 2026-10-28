# DSH 本地插件同步包（加密分发）

这个仓库只放**分发引导**和**加密安装包**：安装包用 AES-256 加密，密码单独告知。

## 一键安装（在那台电脑的 PowerShell 里粘贴）

    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol='Tls12'; iwr 'https://raw.githubusercontent.com/chaojiwudidatanke-oss/dsh-local-plugins-dist/main/install-from-url.ps1' -OutFile $env:TEMP\i.ps1; & $env:TEMP\i.ps1 -Url 'https://github.com/chaojiwudidatanke-oss/dsh-local-plugins-dist/releases/download/v4d801983ea7b/pack-4d801983ea7b.aes'"

会提示输入密码；之后自动下载 → 校验 → 解密 → 解压 → 运行 install.cmd。
**安装前请完全退出 DSH（含托盘）。** 装完重开 DSH，再跑安装目录里的 check.cmd 自检。

## 手动方式

1. 在 Releases 里下载 `pack-*.aes`；
2. 下载本仓库的 `install-from-url.ps1`；
3. `powershell -NoProfile -ExecutionPolicy Bypass -File install-from-url.ps1 -Path <pack.aes 路径>`，输入密码。

## 说明

- 包内含个人技能树与插件数据，因此加密；仓库里没有明文包。
- 版本号 = 包内容 hash；更新流程：开发机重新构建 → 用 `encrypt-pack.mjs` 加密 → 发新 Release。