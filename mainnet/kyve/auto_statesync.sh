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
echo "Auto Installer For Kyve Network";
echo -e "\e[0m"
sleep 1

# Variable
KYVE_WALLET=wallet
KYVE=kyved
KYVE_ID=kyve-1
KYVE_FOLDER=.kyve
KYVE_VER=v1.0.0
KYVE_REPO=https://github.com/KYVENetwork/chain
KYVE_GENESIS=https://files.kyve.network/mainnet/genesis.json
KYVE_ADDRBOOK=https://raw.githubusercontent.com/kynraze/service/main/mainnet/kyve/addrbook.json
KYVE_DENOM=ukyve
KYVE_PORT=15

echo "export KYVE_WALLET=${KYVE_WALLET}" >> $HOME/.bash_profile
echo "export KYVE=${KYVE}" >> $HOME/.bash_profile
echo "export KYVE_ID=${KYVE_ID}" >> $HOME/.bash_profile
echo "export KYVE_FOLDER=${KYVE_FOLDER}" >> $HOME/.bash_profile
echo "export KYVE_VER=${KYVE_VER}" >> $HOME/.bash_profile
echo "export KYVE_REPO=${KYVE_REPO}" >> $HOME/.bash_profile
echo "export KYVE_GENESIS=${KYVE_GENESIS}" >> $HOME/.bash_profile
echo "export KYVE_ADDRBOOK=${KYVE_ADDRBOOK}" >> $HOME/.bash_profile
echo "export KYVE_DENOM=${KYVE_DENOM}" >> $HOME/.bash_profile
echo "export KYVE_PORT=${KYVE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $KYVE_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " KYVE_NODENAME
        echo 'export KYVE_NODENAME='$KYVE_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$KYVE_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$KYVE_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$KYVE_PORT\e[0m"
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
rm -rf chain
rm -rf $KYVE_FOLDER
git clone $KYVE_REPO
cd chain
git checkout $KYVE_VER
make install

# Init generation
$KYVE config chain-id $KYVE_ID
$KYVE config keyring-backend file
$KYVE config node tcp://localhost:${KYVE_PORT}657
$KYVE init $KYVE_NODENAME --chain-id $KYVE_ID

# Set peers and seeds
PEERS="b950b6b08f7a6d5c3e068fcd263802b336ffe047@18.198.182.214:26656,25da6253fc8740893277630461eb34c2e4daf545@3.76.244.30:26656,146d27829fd240e0e4672700514e9835cb6fdd98@34.212.201.1:26656,fae8cd5f04406e64484a7a8b6719eacbb861c094@44.241.103.199:26656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$KYVE_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$KYVE_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $KYVE_GENESIS > $HOME/$KYVE_FOLDER/config/genesis.json
curl -Ls $KYVE_ADDRBOOK > $HOME/$KYVE_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${KYVE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${KYVE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${KYVE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${KYVE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${KYVE_PORT}660\"%" $HOME/$KYVE_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${KYVE_PORT}317\"%; s%^address = \":8080\"%address = \":${KYVE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${KYVE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${KYVE_PORT}091\"%" $HOME/$KYVE_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$KYVE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$KYVE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$KYVE_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$KYVE_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$KYVE_DENOM\"/" $HOME/$KYVE_FOLDER/config/app.toml

$KYVE tendermint unsafe-reset-all --home $HOME/$KYVE_FOLDER --keep-addr-book

STATE_SYNC_RPC="https://kyve-rpc.kynraze.com:443"
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/$KYVE_FOLDER/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
    $HOME/$KYVE_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  $HOME/$KYVE_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/$KYVE_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$KYVE.service > /dev/null << EOF
[Unit]
Description=$KYVE
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $KYVE) start --home $HOME/$KYVE_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $KYVE
sudo systemctl start $KYVE

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $KYVE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${KYVE_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
