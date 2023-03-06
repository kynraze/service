#
#// Copyright (C) 2023 Salman Wahib
#
echo -e "\033[0;31m"
echo "@@@@@@@@ @@@ @@@ @@@@@@ @@@@@@@ @@@@@@@@ @@@ @@@"
echo "@@@@@@@@ @@@@ @@@ @@@@@@@@ @@@@@@@@ @@@@@@@@ @@@ @@@"
echo "@@! @@!@!@@@ @@! @@@ @@! @@@ @@! @@! !@@"
echo "!@! !@!!@!@! !@! @!@ !@! @!@ !@! !@! @!!"
echo "@!!!:! @!@ !!@! @!@ !@! @!@ !@! @!!!:! !@@!@! "
echo "!!!!!: !@! !!! !@! !!! !@! !!! !!!!!: @!!! "
echo "!!: !!: !!! !!: !!! !!: !!! !!: !: :!! "
echo ":!: :!: !:! :!: !:! :!: !:! :!: :!: !:!"
echo " :: :::: :: :: ::::: :: :::: :: :: :::: :: :::"
echo ": :: :: :: : : : : :: : : : :: :: : :: "
echo "Auto Installer For ";
echo -e "\e[0m"
sleep 1
# Variable
_WALLET=d
=
_ID=dd
_FOLDER=
_VER=d
_REPO=
_GENESIS=
_ADDRBOOK=
_DENOM=
_PORT=
echo "export _WALLET=$_WALLET" >> $HOME/.bash_profile
echo "export =$" >> $HOME/.bash_profile
echo "export _ID=$_ID" >> $HOME/.bash_profile
echo "export _FOLDER=$_FOLDER" >> $HOME/.bash_profile
echo "export _VER=$_VER" >> $HOME/.bash_profile
echo "export _REPO=$_REPO" >> $HOME/.bash_profile
echo "export _GENESIS=$_GENESIS" >> $HOME/.bash_profile
echo "export _ADDRBOOK=$_ADDRBOOK" >> $HOME/.bash_profile
echo "export _DENOM=$_DENOM" >> $HOME/.bash_profile
echo "export _PORT=$_PORT" >> $HOME/.bash_profile
source $HOME/.bash_profile
# Set Vars
if [ ! $_NODENAME ]; then
read -p "[ENTER YOUR NODE] > " _NODENAME
echo 'export _NODENAME='$_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$_NODENAME\e[0m"
echo -e "NODE CHAIN NAME : \e[1m\e[31m$_ID\e[0m"
echo -e "NODE PORT : \e[1m\e[31m$_PORT\e[0m"
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
# Get testnet version
cd $HOME
rm -rf chain
git clone $_REPO
cd
git checkout $_VER
make install
# Init generation
$ config-id $_ID
$ config keyring-backend file
$ config node tcp://localhost:${_PORT}657
$ init $_NODENAME --chain-id $_ID
# Set peers and seeds
PEERS=""
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$_FOLDER/config/config.toml
# Download genesis and addrbook
curl -Ls $_GENESIS > $HOME/$_FOLDER/config/genesis.json
curl -Ls $_ADDRBOOK > $HOME/$_FOLDER/config/addrbook.json
#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:{_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${_PORT}660\"%" $HOME/$_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${_PORT}317\"%; s%^address = \":8080\"%address = \":${_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${_PORT}091\"%" $HOME/$_FOLDER/config/app.toml
# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$_FOLDER/config/app.toml
# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"$_DENOM\"/" $HOME/$_FOLDER/config/app.toml
$ tendermint unsafe-reset-all --home $HOME/$_FOLDER --keep-addr-book
STATE_SYNC_RPC=""
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/$_FOLDER/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
$HOME/$_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
$HOME/$_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
$HOME/$_FOLDER/config/config.toml
# Create Service
sudo tee /etc/systemd/system/$.service > /dev/null << EOF
[Unit]
Description=$
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $) start --home $HOME/$_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF
# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $
sudo systemctl start $
echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $ -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
