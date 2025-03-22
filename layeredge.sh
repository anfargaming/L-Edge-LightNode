#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "🚀 Starting setup process..."
rm -rf $HOME/light-node
echo -e "🔗 Cloning repository..."
git clone https://github.com/Layer-Edge/light-node.git && echo -e "✅ Repository cloned!"
cd light-node

echo -e "📥 Downloading and installing dependencies..."
curl -L https://risczero.com/install | bash && echo -e "✅ RISC0 installer downloaded!"

# Ensure RISC0 is in the PATH
export PATH="$HOME/.risc0/bin:$PATH"
echo 'export PATH="$HOME/.risc0/bin:$PATH"' >> ~/.bashrc
source "/root/.bashrc"

# Install RISC0 toolchain (use cargo-risczero instead of stable)
echo -e "🔧 Installing RISC0 toolchain..."
rzup install && echo -e "✅ RISC0 toolchain installed!"
source "/root/.bashrc"

# Verify installation
if ! command -v rzup &> /dev/null; then
    echo -e "${RED}❌ RISC0 toolchain installation failed!${NC}"
    exit 1
fi
echo -e "✅ RISC0 toolchain is available!"

echo -e "🔄 Applying environment variables..."
export GRPC_URL=grpc.testnet.layeredge.io:9090
export CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
export ZK_PROVER_URL=https://layeredge.mintair.xyz/
export API_REQUEST_TIMEOUT=100
export POINTS_API=https://light-node.layeredge.io
echo -e "🔑 Please enter your private key: "
read PRIVATE_KEY
echo -e "✅ Private key set!"
export PRIVATE_KEY

echo -e "🛠️ Building and running risc0-merkle-service..."
cd risc0-merkle-service
cargo clean
cargo build

# Start the risc0 service in a named screen session
screen -dmS risc0-service cargo run

# Check if the screen session was created successfully
if screen -list | grep -q "risc0-service"; then
    echo -e "🚀 risc0-merkle-service is running in a screen session!"
else
    echo -e "${RED}❌ Failed to create screen session for risc0-service!${NC}"
fi

echo -e "🖥️ Starting light-node server in a screen session..."
echo -e "🎉 Setup complete! Both servers are running independently in screen sessions!"
