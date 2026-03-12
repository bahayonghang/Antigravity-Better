# Antigravity Better 部署工具

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
    @echo "  install-to   - 部署到指定目录 (just install-to <路径>)"
    @echo "  restore      - 恢复原始 workbench.html"
    @echo ""
    @echo "示例:"
    @echo "  just install                    # 自动部署"
    @echo "  just install-to \"D:/Apps/Antigravity/resources/app/out/vs/code/electron-browser/workbench\""
    @echo "  just restore                    # 恢复备份"

# 部署 workbench.html 到 Antigravity 安装目录（自动检测）
# macOS 需要 sudo 权限写入 /Applications，会提示输入密码
install:
    #!/usr/bin/env bash
    set -e
    echo "🔐 需要 sudo 权限写入 /Applications 目录"
    if command -v uv >/dev/null 2>&1 && [ -f pyproject.toml ]; then
        sudo uv run python deploy.py deploy
    elif command -v python3 >/dev/null 2>&1; then
        sudo python3 deploy.py deploy
    elif command -v python >/dev/null 2>&1; then
        sudo python deploy.py deploy
    else
        echo "❌ 未找到 Python，请安装 Python 或 uv"
        exit 1
    fi

# 部署到指定目录（手动指定路径）
install-to target_dir:
    #!/usr/bin/env bash
    set -e
    echo "🔐 需要 sudo 权限"
    if command -v uv >/dev/null 2>&1 && [ -f pyproject.toml ]; then
        sudo uv run python deploy.py deploy -t "{{target_dir}}"
    elif command -v python3 >/dev/null 2>&1; then
        sudo python3 deploy.py deploy -t "{{target_dir}}"
    elif command -v python >/dev/null 2>&1; then
        sudo python deploy.py deploy -t "{{target_dir}}"
    else
        echo "❌ 未找到 Python，请安装 Python 或 uv"
        exit 1
    fi

# 恢复原始 workbench.html
restore:
    #!/usr/bin/env bash
    set -e
    echo "🔐 需要 sudo 权限"
    if command -v uv >/dev/null 2>&1 && [ -f pyproject.toml ]; then
        sudo uv run python deploy.py restore
    elif command -v python3 >/dev/null 2>&1; then
        sudo python3 deploy.py restore
    elif command -v python >/dev/null 2>&1; then
        sudo python deploy.py restore
    else
        echo "❌ 未找到 Python，请安装 Python 或 uv"
        exit 1
    fi

# 查看状态（不需要 sudo）
status:
    #!/usr/bin/env bash
    set -e
    if command -v uv >/dev/null 2>&1 && [ -f pyproject.toml ]; then
        uv run python deploy.py status
    elif command -v python3 >/dev/null 2>&1; then
        python3 deploy.py status
    elif command -v python >/dev/null 2>&1; then
        python deploy.py status
    else
        echo "❌ 未找到 Python，请安装 Python 或 uv"
        exit 1
    fi

# 启动图形界面（不需要 sudo）
gui:
    #!/usr/bin/env bash
    set -e
    if command -v uv >/dev/null 2>&1 && [ -f pyproject.toml ]; then
        uv run python deploy.py --gui
    elif command -v python3 >/dev/null 2>&1; then
        python3 deploy.py --gui
    elif command -v python >/dev/null 2>&1; then
        python deploy.py --gui
    else
        echo "❌ 未找到 Python，请安装 Python 或 uv"
        exit 1
    fi
