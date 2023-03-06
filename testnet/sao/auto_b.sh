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
SAOO_WALLET=wallet
SAOO=saod
SAOO_ID=sao-testnet0
SAOO_FOLDER=.sao
SAOO_VER=testnet0
SAOO_REPO=https://github.com/SaoNetwork/sao-consensus
SAOO_GENESIS=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/testnet/sao/genesis.json
SAOO_ADDRBOOK=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/testnet/sao/addrbook.json
SAOO_DENOM=sao
SAOO_PORT=44

echo "export SAOO_WALLET=${SAOO_WALLET}" >> $HOME/.bash_profile
echo "export SAOO=${SAOO}" >> $HOME/.bash_profile
echo "export SAOO_ID=${SAOO_ID}" >> $HOME/.bash_profile
echo "export SAOO_FOLDER=${SAOO_FOLDER}" >> $HOME/.bash_profile
echo "export SAOO_VER=${SAOO_VER}" >> $HOME/.bash_profile
echo "export SAOO_REPO=${SAOO_REPO}" >> $HOME/.bash_profile
echo "export SAOO_GENESIS=${SAOO_GENESIS}" >> $HOME/.bash_profile
echo "export SAOO_ADDRBOOK=${SAOO_ADDRBOOK}" >> $HOME/.bash_profile
echo "export SAOO_DENOM=${SAOO_DENOM}" >> $HOME/.bash_profile
echo "export SAOO_PORT=${SAOO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $SAOO_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " SAOO_NODENAME
        echo 'export SAOO_NODENAME='$SAOO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$SAOO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$SAOO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$SAOO_PORT\e[0m"
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
rm -rf $SAOO_FOLDER
git clone $SAOO_REPO
cd sao-consensus
git checkout $SAOO_VER
make install

# Init generation
$SAOO config chain-id $SAOO_ID
$SAOO config keyring-backend file
$SAOO config node tcp://localhost:${SAOO_PORT}657
$SAOO init $SAOO_NODENAME --chain-id $SAOO_ID

# Set peers and seeds
PEERS="2aad459c0dd3a81b1d5eb297986c8d8309ad20e3@peers-sao.sxlzptprjkt.xyz:27656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$SAOO_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$SAOO_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $SAOO_GENESIS > $HOME/$SAOO_FOLDER/config/genesis.json
curl -Ls $SAOO_ADDRBOOK > $HOME/$SAOO_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SAOO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SAOO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SAOO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SAOO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SAOO_PORT}660\"%" $HOME/$SAOO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SAOO_PORT}317\"%; s%^address = \":8080\"%address = \":${SAOO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SAOO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SAOO_PORT}091\"%" $HOME/$SAOO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$SAOO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$SAOO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$SAOO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$SAOO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$SAOO_DENOM\"/" $HOME/$SAOO_FOLDER/config/app.toml

$SAOO tendermint unsafe-reset-all --home $HOME/$SAOO_FOLDER --keep-addr-book

# Create Service
sudo tee /etc/systemd/system/$SAOO.service > /dev/null << EOF
[Unit]
Description=$SAOO
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $SAOO) start --home $HOME/$SAOO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $SAOO
sudo systemctl start $SAOO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $SAOO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${SAOO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
