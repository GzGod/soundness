#!/bin/bash

# 安装必要的依赖（适用于 Debian/Ubuntu）
apt update
apt install -y pkg-config libssl-dev

# 非交互式安装 Rust 和 Cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 加载 Rust 环境变量
source "$HOME/.cargo/env"

# 验证 Rust 是否安装成功
if ! command -v cargo &> /dev/null; then
    echo "错误：Rust/Cargo 未正确安装。"
    exit 1
fi

# 安装 soundnessup
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash

# 确保 PATH 包含 Cargo 的 bin 目录
export PATH="$HOME/.cargo/bin:$PATH"

# 调试：检查 PATH 和二进制文件
echo "当前 PATH: $PATH"
ls -l "$HOME/.cargo/bin/soundnessup" || echo "警告：soundnessup 二进制文件未找到。"

# 验证 soundnessup 命令
if ! command -v soundnessup &> /dev/null; then
    echo "错误：未找到 soundnessup 命令，请检查安装是否正确。"
    exit 1
fi

# 安装和更新 CLI 环境
soundnessup install
soundnessup update

# 验证 soundness-cli 命令
if ! command -v soundness-cli &> /dev/null; then
    echo "错误：未找到 soundness-cli 命令，请检查 'soundnessup install' 是否成功完成。"
    exit 1
fi

# 生成密钥对
soundness-cli generate-key --name my-key
