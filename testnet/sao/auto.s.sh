#
#// Copyright (C) 2023 Salman Wahib
#
echo -e "\033[38;2;4;204;255m"
echo "▄▄▄▄▄▄▄▄▄▄▄                               ▄▄▄▄                        "
echo " ███    ██  ▄▄ ▄▄▄▄▄▄    ▄▄▄▄▄▄▄     ▄▄▄▄▄███  ▄▄▄▄▄▄▄▄▄█ ▄▄▄▄   ▄▄▄▄ "
echo " ███▄▄▄█     ███   ███ ███     ███ ███    ███ ███▄▄▄▄▄▄█    ███▄███   "
echo " ███    ▄▄   ███   ███ ███     ███ ███    ███ ███           ▄██ ██▄   "
echo "▄███▄▄▄████ ▄███▄ ▄███▄  ██▄▄▄██     ██▄▄▄███▄  ██▄▄▄▄███ ▄██▄   ▄██▄ "
echo "Auto Installer For Sao Network";
echo -e "\e[0m"
sleep 1

# Variable
SAOD_WALLET=wallet
SAOD=saod
SAOD_ID=sao-testnet0
SAOD_FOLDER=.sao
SAOD_VER=testnet0
SAOD_REPO=https://github.com/SaoNetwork/sao-consensus
SAOD_GENESIS=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/testnet/sao/genesis.json
SAOD_ADDRBOOK=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/testnet/sao/addrbook.json
SAOD_DENOM=sao
SAOD_PORT=77

echo "export SAOD_WALLET=${SAOD_WALLET}" >> $HOME/.bash_profile
echo "export SAOD=${SAOD}" >> $HOME/.bash_profile
echo "export SAOD_ID=${SAOD_ID}" >> $HOME/.bash_profile
echo "export SAOD_FOLDER=${SAOD_FOLDER}" >> $HOME/.bash_profile
echo "export SAOD_VER=${SAOD_VER}" >> $HOME/.bash_profile
echo "export SAOD_REPO=${SAOD_REPO}" >> $HOME/.bash_profile
echo "export SAOD_GENESIS=${SAOD_GENESIS}" >> $HOME/.bash_profile
echo "export SAOD_ADDRBOOK=${SAOD_ADDRBOOK}" >> $HOME/.bash_profile
echo "export SAOD_DENOM=${SAOD_DENOM}" >> $HOME/.bash_profile
echo "export SAOD_PORT=${SAOD_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $SAOD_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " SAOD_NODENAME
        echo 'export SAOD_NODENAME='$SAOD_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$SAOD_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$SAOD_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$SAOD_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get Repo And Install
cd $HOME
rm -rf sao-consensus
rm -rf $SAOD_FOLDER
git clone $SAOD_REPO
cd sao-consensus
git checkout $SAOD_VER
make install

# Init generation
$SAOD config chain-id $SAOD_ID
$SAOD config keyring-backend file
$SAOD config node tcp://localhost:${SAOD_PORT}657
$SAOD init $SAOD_NODENAME --chain-id $SAOD_ID

# Set peers and seeds
PEERS="2aad459c0dd3a81b1d5eb297986c8d8309ad20e3@peers-sao.sxlzptprjkt.xyz:27656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$SAOD_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$SAOD_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $SAOD_GENESIS > $HOME/$SAOD_FOLDER/config/genesis.json
curl -Ls $SAOD_ADDRBOOK > $HOME/$SAOD_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SAOD_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SAOD_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SAOD_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SAOD_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SAOD_PORT}660\"%" $HOME/$SAOD_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SAOD_PORT}317\"%; s%^address = \":8080\"%address = \":${SAOD_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SAOD_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SAOD_PORT}091\"%" $HOME/$SAOD_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$SAOD_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$SAOD_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$SAOD_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$SAOD_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$SAOD_DENOM\"/" $HOME/$SAOD_FOLDER/config/app.toml

$SAOD tendermint unsafe-reset-all --home $HOME/$SAOD_FOLDER --keep-addr-book

STATE_SYNC_RPC="https://rpc.sao.apramweb.tech:443"
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/$SAOD_FOLDER/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
    $HOME/$SAOD_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  $HOME/$SAOD_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/$SAOD_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$SAOD.service > /dev/null << EOF
[Unit]
Description=$SAOD
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $SAOD) start --home $HOME/$SAOD_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $SAOD
sudo systemctl start $SAOD

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $SAOD -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${SAOD_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
