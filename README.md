# L-Edge-LightNode

## Overview
LayerEdge is the first decentralized network that enhances the capabilities of Bitcoin Blockspace with ZK & BitVM, enabling every layer to be secured on Bitcoin.

# Installation & Setup

## 1. Install Screen 
```bash
apt-install screen
```
```bash
screen -S lightnode
```

## 2. Install Light-Node
```bash
wget https://raw.githubusercontent.com/0xtnpxsgt/L-Edge-LightNode/refs/heads/main/layeredge.sh -O layeredge.sh && chmod +x layeredge.sh && ./layeredge.sh
```

```bash
cd $HOME/light-node/
screen -S lightnode
```
## 3.create .env file
```
nano .env
```
- Copy & Paste This 
- Add Your Private Key: PRIVATE_KEY=XXXXXXXXXXXXXXXXXXXXX
```
GRPC_URL=34.31.74.109:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=http://127.0.0.1:3001
API_REQUEST_TIMEOUT=100
POINTS_API=http://127.0.0.1:8080
PRIVATE_KEY='your-cli-node-private-key'
```

## 4.run light node
```
go build
./light-node
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
