#!/bin/bash

# ========= 环境准备 =========
apt update
apt install -y pkg-config libssl-dev expect curl git -y

# 安装 Rust 和 Cargo
if ! command -v cargo &> /dev/null; then
  echo "🛠️ 安装 Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# 验证 Rust
if ! command -v cargo &> /dev/null; then
  echo "❌ Rust/Cargo 安装失败"
  exit 1
fi

# 安装 soundnessup
if ! command -v soundnessup &> /dev/null; then
  echo "🌐 安装 soundnessup..."
  curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash
  export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
fi

# 初始化 CLI 环境
soundnessup install
soundnessup update

# 验证 soundness-cli
if ! command -v soundness-cli &> /dev/null; then
  echo "❌ 未找到 soundness-cli"
  exit 1
fi

# 安装 pm2（如未安装）
if ! command -v pm2 &> /dev/null; then
  echo "📦 安装 pm2..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
  apt install -y nodejs
  npm install -g pm2
fi

# ========= 写入 expect 自动交互脚本 =========
cat > generate_key.expect <<EOF
#!/usr/bin/expect -f
set timeout -1
set password "$PASSWORD_KEY"

log_user 1

spawn soundness-cli generate-key --name my-key
expect "Enter password for secret key:"
send "\$password\r"
expect "Confirm password:"
send "\$password\r"
expect eof
EOF

chmod +x generate_key.expect

# ========= 写入包装 shell 脚本 =========
cat > run_expect.sh <<EOF
#!/bin/bash
expect ./generate_key.expect
EOF

chmod +x run_expect.sh

# ========= 使用 pm2 启动脚本 =========
echo "🚀 使用 pm2 启动密钥生成任务..."
pm2 delete soundness &>/dev/null
pm2 start ./run_expect.sh --name soundness --output ./soundnesskey.txt --error ./soundnesskey.txt --log-date-format 'YYYY-MM-DD HH:mm:ss'

echo "✅ pm2 任务已启动，名称：soundness"
echo "📄 密钥信息将保存到 soundnesskey.txt"
