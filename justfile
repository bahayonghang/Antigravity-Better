# Antigravity Better 部署工具

set windows-shell := ["pwsh.exe", "-NoLogo", "-NoProfile", "-Command"]

python_runner := if os_family() == 'windows' { 'python' } else { 'python3' }

sudo_prefix := if os_family() == 'windows' { '' } else { 'sudo ' }

# 列出所有可用命令
default:
    @just --list

# 显示帮助信息
help:
    @echo "Antigravity Better 部署工具"
    @echo ""
    @echo "用法：just <命令>"
    @echo ""
    @echo "命令:"
    @echo "  install      - 自动检测并部署到 Antigravity 安装目录"
    @echo "  redeploy     - 强制重新部署（先恢复备份，再重新覆盖）"
    @echo "  install-to   - 部署到指定目录 (just install-to <路径>)"
    @echo "  restore      - 恢复原始 workbench.html"
    @echo ""
    @echo "示例:"
    @echo "  just install                    # 自动部署"
    @echo "  just redeploy                   # 强制重新部署"
    @echo "  just install-to \"D:/Apps/Antigravity/resources/app/out/vs/code/electron-browser/workbench\""
    @echo "  just restore                    # 恢复备份"

# 部署 workbench.html 到 Antigravity 安装目录（自动检测）
# macOS 需要 sudo 权限写入 /Applications，会提示输入密码
install:
    @{{ if os_family() == 'windows' { 'echo "⚠️ 如 Antigravity 安装在 Program Files，可能需要以管理员身份运行终端。"' } else { 'echo "🔐 需要 sudo 权限写入 Antigravity.app"' } }}
    @{{ sudo_prefix + python_runner + ' deploy.py deploy' }}

# 强制重新部署（先恢复，再覆盖）
redeploy:
    @{{ if os_family() == 'windows' { 'echo "⚠️ 如 Antigravity 安装在 Program Files，可能需要以管理员身份运行终端。"' } else { 'echo "🔐 需要 sudo 权限重新部署 Antigravity.app"' } }}
    @{{ sudo_prefix + python_runner + ' deploy.py redeploy' }}

# 部署到指定目录（手动指定路径）
install-to target_dir:
    @{{ if os_family() == 'windows' { 'echo "⚠️ 如目标目录受保护，可能需要以管理员身份运行终端。"' } else { 'echo "🔐 如目标目录需要写权限，将请求 sudo。"' } }}
    @{{ sudo_prefix + python_runner + " deploy.py deploy -t '" + target_dir + "'" }}

# 恢复原始 workbench.html
restore:
    @{{ if os_family() == 'windows' { 'echo "⚠️ 如 Antigravity 安装在 Program Files，可能需要以管理员身份运行终端。"' } else { 'echo "🔐 需要 sudo 权限恢复 Antigravity.app 中的备份文件"' } }}
    @{{ sudo_prefix + python_runner + ' deploy.py restore' }}

# 查看状态（不需要 sudo）
status:
    @{{ python_runner + ' deploy.py status' }}

# 启动图形界面（不需要 sudo）
gui:
    @{{ python_runner + ' deploy.py --gui' }}
