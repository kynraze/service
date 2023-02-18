#

echo "      Auto Installer For KYVE Chain     ";
echo -e "\e[0m"
sleep 1

# Variable
KYVE_WALLET=wallet
KYVE=kyved
KYVE_ID=kaon-1
KYVE_FOLDER=.kyve
KYVE_VER=v1.0.0-rc0
KYVE_REPO=https://github.com/KYVENetwork/chain
KYVE_GENESIS=https://snap.enodex.lol/addrbook/test-kyve/genesis.json
KYVE_ADDRBOOK=https://snap.enodex.lol/addrbook/test-kyve/addrbook.json
KYVE_DENOM=tkyve
KYVE_PORT=10

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
if [ ! $ORDOS_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " KYVE_NODENAME
        echo 'export ORDOS_NODENAME='$KYVE_NODENAME >> $HOME/.bash_profile
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

# Get testnet version of alliance (terra)
cd $HOME
rm -rf chain
git clone $ORDOS_REPO
cd alliance
git checkout $ORDOS_VER
make build ACC_PREFIX=kyve
sudo mv build/$KYVE /usr/local/bin/

# Init generation
$KYVE config chain-id $KYVE_ID
$KYVE config keyring-backend file
$KYVE config node tcp://localhost:${KYVE_PORT}657
$KYVE init $KYVE_NODENAME --chain-id $KYVE_ID

# Set peers and seeds
PEERS="664e06d2d6110c5ba93f8ecfee66f150bad981bf@kyve-testnet-peer.itrocket.net:443"
SEEDS="de7865a2a4936fd4bb00861ed887f219d8dd73d7@kyve-testnet-seed.itrocket.net:443"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$KYVE_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$KYVE_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $KYVE_GENESIS > $HOME/$KYVE_FOLDER/config/genesis.json
curl -Ls $KYVE_ADDRBOOK > $HOME/$KYVE_FOLDER/config/addrbook.json

# Set Port
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
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$ORDOS_DENOM\"/" $HOME/$ORDOS_FOLDER/config/app.toml


# Create Service
sudo tee /etc/systemd/system/$KYVE.service > /dev/null <<EOF
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
