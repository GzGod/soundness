#!/bin/bash

# 安装 Rust 和 Cargo，自动选择默认选项（非交互式安装）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 加载 Rust 的环境变量
source /root/.cargo/env

# 运行官方安装命令
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash

# 刷新环境变量（以 root 身份运行时使用 /root/.bashrc）
source /root/.bashrc

# 手动确保 PATH 包含 /root/.cargo/bin
export PATH="$PATH:/root/.cargo/bin"

# 验证 soundnessup 命令是否可用
if ! command -v soundnessup &> /dev/null; then
    echo "错误：未找到 soundnessup 命令，请检查安装是否正确。"
    exit 1
fi

# 安装和更新 CLI 环境
soundnessup install
soundnessup update

# 验证 soundness-cli 命令是否可用
if ! command -v soundness-cli &> /dev/null; then
    echo "错误：未找到 soundness-cli 命令，请检查 'soundnessup install' 是否成功完成。"
    exit 1
fi


# 生成密钥对
soundness-cli generate-key --name my-key
