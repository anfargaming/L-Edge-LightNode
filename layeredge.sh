#!/bin/bash

# LayerEdge CLI Light Node Automatic Installation Script

set -e
clear 

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run the button logo script (optional branding)
curl -sL https://raw.githubusercontent.com/0xtnpxsgt/logo/refs/heads/main/logo.sh | bash

# Cleanup function to remove existing installations
cleanup() {
    echo -e "${GREEN}Cleaning up previous installations...${NC}"
    # Remove previous light-node directory if it exists
    if [ -d "light-node" ]; then
        rm -rf light-node
    fi
    # Kill any running processes related to light-node or merkle service
    pkill -f './light-node' 2>/dev/null || true
    pkill -f 'cargo run' 2>/dev/null || true
    # Remove temporary Go files
    rm -f go1.21.8.linux-amd64.tar.gz 2>/dev/null
    echo "Cleanup complete."
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
    echo "Checking dependencies..."

    # Check and install Go
    if ! command_exists go; then
        echo "Installing Go..."
        wget https://golang.org/dl/go1.21.8.linux-amd64.tar.gz
        sudo tar -C /usr/local -xzf go1.21.8.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        source ~/.bashrc
    fi

    # Check and install Rust manually before installing Risc0
    if ! command_exists rustc; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Verify Rust installation
    if ! command_exists rustc; then
        echo -e "${RED}Rust installation failed. Please check manually.${NC}"
        exit 1
    fi
    echo "Rust installed: $(rustc --version)"

    # Check and install Risc0 Toolchain
    if ! command_exists rzup; then
        echo "Installing Risc0 Toolchain..."
        curl -L https://risczero.com/install | bash
        export PATH="$HOME/.risc0/bin:$PATH"
        echo 'export PATH="$HOME/.risc0/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
    fi

    # Verify Risc0 installation
    if ! command_exists rzup; then
        echo -e "${RED}Risc0 installation failed. Check if $HOME/.risc0/bin exists and contains rzup.${NC}"
        exit 1
    fi
    echo "Risc0 Toolchain verified: $(rzup --version)"
}

# Clone repository and navigate
setup_repository() {
    echo "Cloning LayerEdge Light Node repository..."
    git clone https://github.com/Layer-Edge/light-node.git
    cd light-node || exit
}

# Get user private key and configure environment
configure_environment() {
    echo -e "\n${GREEN}Please enter your private key for the CLI node:${NC}"
    read -p "Enter your private key: " private_key < /dev/tty || {
        echo -e "${RED}Error: Failed to read input. Please run in an interactive terminal.${NC}"
        exit 1
    }
    echo

    if [ -z "$private_key" ]; then
        echo -e "${RED}Error: No private key entered. Please try again.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Private key captured: $private_key${NC}"

    cat > .env << EOL
GRPC_URL=34.31.74.109:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=http://127.0.0.1:3001
API_REQUEST_TIMEOUT=100
POINTS_API=http://127.0.0.1:8080
PRIVATE_KEY=$private_key
EOL

    source .env
}

# Build and start Merkle service
start_merkle_service() {
    echo "Building and starting Merkle service..."
    cd risc0-merkle-service || exit
    cargo build
    cargo run &
    MERKLE_PID=$!
    sleep 5
    cd ..
}

# Build and run Light Node
run_light_node() {
    echo "Building and running LayerEdge Light Node..."
    go build
    ./light-node &
    NODE_PID=$!
}

# Display connection information
show_connection_info() {
    echo -e "\n${GREEN}Setup Complete!${NC}"
    echo "Your CLI node is running with wallet private key configured"
    echo "To connect to dashboard:"
    echo "1. Visit: dashboard.layeredge.io"
    echo "2. Connect your wallet"
    echo "3. Link your CLI node's Public Key"
    echo -e "\nTo check points, use API:"
    echo "https://light-node.layeredge.io/api/cli-node/points/{walletAddress}"
    echo -e "\nFor support, join: discord.gg/layeredge"
}

# Main execution
main() {
    cleanup
    check_dependencies
    setup_repository
    configure_environment
    start_merkle_service
    run_light_node
    show_connection_info

    echo -e "\n${GREEN}Installation completed successfully!${NC}"
    echo "Merkle service PID: $MERKLE_PID"
    echo "Light Node PID: $NODE_PID"
    echo "To stop the services, use: kill $MERKLE_PID $NODE_PID"
}

# Error handling
trap 'echo -e "${RED}An error occurred. Installation failed.${NC}"; exit 1' ERR

main
