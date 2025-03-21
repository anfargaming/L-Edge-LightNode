#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run the button logo script (optional branding)
curl -sL https://raw.githubusercontent.com/0xtnpxsgt/logo/refs/heads/main/logo.sh | bash
sleep 5

echo -e "🚀 Starting setup process..."
rm -rf $HOME/light-node

echo -e "🔗 Cloning repository..."
git clone https://github.com/Layer-Edge/light-node.git && echo -e "✅ Repository cloned!"

cd ~/light-node

echo -e "📥 Downloading and installing dependencies..."
curl -L https://risczero.com/install | bash && echo -e "✅ Dependencies installed!"

# Add risc0 to PATH
export PATH="$HOME/.risc0/bin:$PATH"
echo 'export PATH="$HOME/.risc0/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo -e "🔄 Applying environment variables..."
export GRPC_URL=grpc.testnet.layeredge.io:9090
export CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
export ZK_PROVER_URL=https://layeredge.mintair.xyz/
export API_REQUEST_TIMEOUT=100
export POINTS_API=https://light-node.layeredge.io

# Ask user for PRIVATE_KEY
echo -e "🔑 Please enter your private key: "
read PRIVATE_KEY
echo "export PRIVATE_KEY=$PRIVATE_KEY" >> ~/.bashrc
source ~/.bashrc
echo -e "✅ Private key set!"

echo -e "🛠️ Building and running risc0-merkle-service..."
cd ~/light-node/risc0-merkle-service
cargo build && screen -dmS risc0-service cargo run && echo -e "🚀 risc0-merkle-service is running in a screen session!"

echo -e "🖥️ Starting light-node server in a screen session..."
cd ~/light-node
screen -dmS light-node cargo run && echo -e "✅ Light-node server is running in a screen session!"

echo -e "🎉 Setup complete! Both servers are running independently in screen sessions!"
