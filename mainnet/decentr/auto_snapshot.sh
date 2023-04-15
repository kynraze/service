#
echo -e "\033[38;2;4;204;255m"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  ██╗  ██╗██╗   ██╗███╗   ██╗██████╗  █████╗ ███████╗███████╗  ║"
echo "║  ██║ ██╔╝╚██╗ ██╔╝████╗  ██║██╔══██╗██╔══██╗╚══███╔╝██╔════╝  ║"
echo "║  █████╔╝  ╚████╔╝ ██╔██╗ ██║██████╔╝███████║  ███╔╝ █████╗    ║"
echo "║  ██╔═██╗   ╚██╔╝  ██║╚██╗██║██╔══██╗██╔══██║ ███╔╝  ██╔══╝    ║"
echo "║  ██║  ██╗   ██║   ██║ ╚████║██║  ██║██║  ██║███████╗███████╗  ║"
echo "║  ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo "Auto Installer For Decentr";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
DECENTR_WALLET=wallet
DECENTR=decentr
DECENTR_ID=mainnet-3
DECENTR_FOLDER=.decentr
DECENTR_VER=v1.6.2
DECENTR_REPO=https://github.com/Decentr-net/decentr
DECENTR_GENESIS=https://snap.kynraze.com/decentr/genesis.json
DECENTR_ADDRBOOK=https://snap.kynraze.com/decentr/addrbook.json
DECENTR_DENOM=udec
DECENTR_PORT=14

echo "export DECENTR_WALLET=${DECENTR_WALLET}" >> $HOME/.bash_profile
echo "export DECENTR=${DECENTR}" >> $HOME/.bash_profile
echo "export DECENTR_ID=${DECENTR_ID}" >> $HOME/.bash_profile
echo "export DECENTR_FOLDER=${DECENTR_FOLDER}" >> $HOME/.bash_profile
echo "export DECENTR_VER=${DECENTR_VER}" >> $HOME/.bash_profile
echo "export DECENTR_REPO=${DECENTR_REPO}" >> $HOME/.bash_profile
echo "export DECENTR_GENESIS=${DECENTR_GENESIS}" >> $HOME/.bash_profile
echo "export DECENTR_ADDRBOOK=${DECENTR_ADDRBOOK}" >> $HOME/.bash_profile
echo "export DECENTR_DENOM=${DECENTR_DENOM}" >> $HOME/.bash_profile
echo "export DECENTR_PORT=${DECENTR_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $DECENTR_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " DECENTR_NODENAME
        echo 'export DECENTR_NODENAME='$DECENTR_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$DECENTR_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$DECENTR_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$DECENTR_PORT\e[0m"
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
rm -rf decentr
rm -rf $DECENTR_FOLDER
git clone $DECENTR_REPO
cd decentr
git checkout $DECENTR_VER
make install

# Init generation
$DECENTR config chain-id $DECENTR_ID
$DECENTR config keyring-backend file
$DECENTR config node tcp://localhost:${DECENTR_PORT}657
$DECENTR init $DECENTR_NODENAME --chain-id $DECENTR_ID

# Set peers and seeds
PEERS="$(curl -sS https://decentr-rpc.kynraze.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$DECENTR_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$DECENTR_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $DECENTR_GENESIS > $HOME/$DECENTR_FOLDER/config/genesis.json
curl -Ls $DECENTR_ADDRBOOK > $HOME/$DECENTR_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DECENTR_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DECENTR_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DECENTR_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DECENTR_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DECENTR_PORT}660\"%" $HOME/$DECENTR_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DECENTR_PORT}317\"%; s%^address = \":8080\"%address = \":${DECENTR_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DECENTR_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DECENTR_PORT}091\"%" $HOME/$DECENTR_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$DECENTR_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$DECENTR_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$DECENTR_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$DECENTR_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$DECENTR_DENOM\"/" $HOME/$DECENTR_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$DECENTR_FOLDER/config/app.toml

$DECENTR tendermint unsafe-reset-all --home $HOME/$DECENTR_FOLDER --keep-addr-book

curl -L https://snap.kynraze.com/decentr/snapshot-latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$DECENTR_FOLDER

# Create Service
sudo tee /etc/systemd/system/$DECENTR.service > /dev/null << EOF
[Unit]
Description=$DECENTR
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $DECENTR) start --home $HOME/$DECENTR_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $DECENTR
sudo systemctl start $DECENTR

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $DECENTR -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${DECENTR_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
