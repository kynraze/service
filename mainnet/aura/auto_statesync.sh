#
echo -e "\033[38;2;4;204;255m"
echo "======================================================================"
echo "██╗  ██╗██╗   ██╗███╗   ██╗██████╗  █████╗ ███████╗███████╗"
echo "██║ ██╔╝╚██╗ ██╔╝████╗  ██║██╔══██╗██╔══██╗╚══███╔╝██╔════╝"
echo "█████╔╝  ╚████╔╝ ██╔██╗ ██║██████╔╝███████║  ███╔╝ █████╗  "
echo "██╔═██╗   ╚██╔╝  ██║╚██╗██║██╔══██╗██╔══██║ ███╔╝  ██╔══╝  "
echo "██║  ██╗   ██║   ██║ ╚████║██║  ██║██║  ██║███████╗███████╗"
echo "╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝"
echo "======================================================================"
echo "Auto Installer For Aura Network";
echo -e "\e[0m"
sleep 1

# Variable
AURA_WALLET=wallet
AURA=aurad
AURA_ID=xstaxy-1
AURA_FOLDER=.aura
AURA_VER=aura_v0.4.4
AURA_REPO=https://github.com/aura-nw/aura
AURA_GENESIS=https://raw.githubusercontent.com/kynraze/service/main/mainnet/aura/genesis.json
AURA_ADDRBOOK=https://snapshots.nodestake.top/aura/addrbook.json
AURA_DENOM=uaura
AURA_PORT=31

echo "export AURA_WALLET=${AURA_WALLET}" >> $HOME/.bash_profile
echo "export AURA=${AURA}" >> $HOME/.bash_profile
echo "export AURA_ID=${AURA_ID}" >> $HOME/.bash_profile
echo "export AURA_FOLDER=${AURA_FOLDER}" >> $HOME/.bash_profile
echo "export AURA_VER=${AURA_VER}" >> $HOME/.bash_profile
echo "export AURA_REPO=${AURA_REPO}" >> $HOME/.bash_profile
echo "export AURA_GENESIS=${AURA_GENESIS}" >> $HOME/.bash_profile
echo "export AURA_ADDRBOOK=${AURA_ADDRBOOK}" >> $HOME/.bash_profile
echo "export AURA_DENOM=${AURA_DENOM}" >> $HOME/.bash_profile
echo "export AURA_PORT=${AURA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $AURA_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " AURA_NODENAME
        echo 'export AURA_NODENAME='$AURA_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$AURA_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$AURA_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$AURA_PORT\e[0m"
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
rm -rf aura
rm -rf $AURA_FOLDER
git clone $AURA_REPO
cd aura
git checkout $AURA_VER
make install

# Init generation
$AURA config chain-id $AURA_ID
$AURA config keyring-backend file
$AURA config node tcp://localhost:${AURA_PORT}657
$AURA init $AURA_NODENAME --chain-id $AURA_ID

# Set peers and seeds
PEERS="3e7ef25f1c9829351936884618659167400eb0f1@142.132.149.171:26656,ed15ae05f17dd4e672eec0a96c38364d063b68dc@65.108.6.45:60756,7885a9e940b45b9a2183488ca3a901b043b6ed67@144.76.40.53:21756,a19b89ebbf7331f435b8ef100ce501d2377922ea@209.126.116.182:26656,e46238ddcf2113b70f59b417994c375e2d67e265@71.236.119.108:40656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$AURA_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$AURA_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $AURA_GENESIS > $HOME/$AURA_FOLDER/config/genesis.json
curl -Ls $AURA_ADDRBOOK > $HOME/$AURA_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${AURA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${AURA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${AURA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${AURA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${AURA_PORT}660\"%" $HOME/$AURA_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${AURA_PORT}317\"%; s%^address = \":8080\"%address = \":${AURA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${AURA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${AURA_PORT}091\"%" $HOME/$AURA_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$AURA_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$AURA_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$AURA_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$AURA_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025$AURA_DENOM\"/" $HOME/$AURA_FOLDER/config/app.toml

$AURA tendermint unsafe-reset-all --home $HOME/$AURA_FOLDER --keep-addr-book

STATE_SYNC_RPC="https://rpc.cosmos.directory:443"
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/$AURA_FOLDER/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
    $HOME/$AURA_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  $HOME/$AURA_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/$AURA_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$AURA.service > /dev/null << EOF
[Unit]
Description=$AURA
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $AURA) start --home $HOME/$AURA_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $AURA
sudo systemctl start $AURA

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $AURA -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${AURA_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
