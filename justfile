# Antigravity Better 部署工具

# 列出所有可用命令
default:
    @just --list

# 显示帮助信息
help:
    @echo "Antigravity Better 部署工具"
    @echo ""
    @echo "用法: just <命令>"
    @echo ""
    @echo "命令:"
    @echo "  install      - 自动检测并部署到 Antigravity 安装目录"
    @echo "  install-to   - 部署到指定目录 (just install-to <路径>)"
    @echo "  restore      - 恢复原始 workbench.html"
    @echo ""
    @echo "示例:"
    @echo "  just install                    # 自动部署"
    @echo "  just install-to \"D:/Apps/Antigravity/resources/app/out/vs/code/electron-browser/workbench\""
    @echo "  just restore                    # 恢复备份"

# 部署 workbench.html 到 Antigravity 安装目录（自动检测）
install:
    python deploy.py deploy

# 部署到指定目录（手动指定路径）
install-to target_dir:
    python deploy.py deploy -t "{{target_dir}}"

# 恢复原始 workbench.html
restore:
    python deploy.py restore

# 查看状态
status:
    python deploy.py status

# 启动图形界面
gui:
    python deploy.py --gui
