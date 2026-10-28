# DSH 本地插件同步包（公开分发）

给另一台 Windows 电脑装 3 个本地插件的一次性离线安装包：

- @local/dsh-skills-button —— 输入框「✦ 技能」按钮（含常用技能收藏）
- @local/dsh-skills-page —— 左侧栏「技能」整页（清点 / 次数 / 开关 / 导入卸载）
- @local/dsh-draft-keeper —— 草稿图片跨会话保持

## 下载

- 安装包在 **Releases**：`dsh-local-plugins-sync-4d801983ea7b.zip`（当前 v4d801983ea7b）
- 直链：https://github.com/chaojiwudidatanke-oss/dsh-local-plugins-dist/releases/download/v4d801983ea7b/dsh-local-plugins-sync-4d801983ea7b.zip
- SHA256：5375AFF2B24F76736260A1B9AC65EC288299A992E681B88E5A00D2A5AF38C709

## 安装（四步）

1. 下载 zip 并解压（路径含中文/空格都行）
2. 完全退出 DSH（连托盘一起退出）
3. 双击解压目录里的 install.cmd（会逐行打印 STEP 1..9）
4. 重开 DSH → 双击 check.cmd 自检（约 2 分钟，逐项打印；`host-smoke:dsh-draft-keeper` 那行 SKIP 属正常）

## 一条命令（可选）

    powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr 'https://github.com/chaojiwudidatanke-oss/dsh-local-plugins-dist/releases/download/v4d801983ea7b/dsh-local-plugins-sync-4d801983ea7b.zip' -OutFile $env:TEMP\s.zip; Expand-Archive $env:TEMP\s.zip $env:TEMP\s -Force; & $env:TEMP\s\install.cmd"

## 说明

- 包里含个人技能树与插件数据（技能按钮收藏、技能页开关记录），所以装出来和来源机器一致。
- 本仓库是**公开**的：拿到链接的人都能下载这个包；如果以后想收回，把仓库/Release 改私有或删除即可。
- 版本号 = 包内容 hash；更新流程：开发机重新构建 → 本仓库发新 Release → 目标机重下并重跑 install.cmd。
- 前置条件：目标机已装 DSH 并至少启动过一次（提供 node/pnpm 运行时）；无需管理员权限、无需联网（下载包本身除外）。