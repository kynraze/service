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
echo "Auto Installer For Realio Network";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
REALIO_WALLET=wallet
REALIO=realio-networkd
REALIO_ID=realionetwork_3301-1
REALIO_FOLDER=.realio-network
REALIO_VER=v0.8.0-rc4
REALIO_REPO=https://github.com/realiotech/realio-network.git
REALIO_GENESIS=https://raw.githubusercontent.com/kynraze/service/main/mainnet/realio/genesis.json
REALIO_ADDRBOOK=https://snap.kynraze.com/realio/addrbook.json
REALIO_DENOM=ario
REALIO_PORT=10

echo "export REALIO_WALLET=${REALIO_WALLET}" >> $HOME/.bash_profile
echo "export REALIO=${REALIO}" >> $HOME/.bash_profile
echo "export REALIO_ID=${REALIO_ID}" >> $HOME/.bash_profile
echo "export REALIO_FOLDER=${REALIO_FOLDER}" >> $HOME/.bash_profile
echo "export REALIO_VER=${REALIO_VER}" >> $HOME/.bash_profile
echo "export REALIO_REPO=${REALIO_REPO}" >> $HOME/.bash_profile
echo "export REALIO_GENESIS=${REALIO_GENESIS}" >> $HOME/.bash_profile
echo "export REALIO_ADDRBOOK=${REALIO_ADDRBOOK}" >> $HOME/.bash_profile
echo "export REALIO_DENOM=${REALIO_DENOM}" >> $HOME/.bash_profile
echo "export REALIO_PORT=${REALIO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $REALIO_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " REALIO_NODENAME
        echo 'export REALIO_NODENAME='$REALIO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$REALIO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$REALIO_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$REALIO_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$REALIO\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$REALIO_DENOM\e[0m"
echo ""
sleep 15

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
rm -rf realio-network
git clone $REALIO_REPO
cd realio-network
git checkout $REALIO_VER
make install

# Init generation
$REALIO config chain-id $REALIO_ID
$REALIO config keyring-backend file
$REALIO config node tcp://localhost:${REALIO_PORT}657
$REALIO init $REALIO_NODENAME --chain-id $REALIO_ID

# Set peers and seeds
PEERS="d99c807a58f876684618af016409a09186065851@173.249.59.70:32656,a09acd01e40c94b58cb9109fa74ce53c2220fd26@161.97.182.71:46656,daea809589ac871c6c9f450ca1cdfd5ab2320e06@57.128.110.81:26656,2815cc1437461f808a7f022c0df679fa27918dbc@65.109.116.151:23656,b2e50a471151aecedde282055a8f0e829aa2170b@65.109.29.224:28656,2c832dcd9e41d988fadf8d1af8d95640ce009398@65.21.90.141:12263,00b261d9c9b845ce42964a3a3f6c68173875e981@65.109.28.177:30656,759b796d1f7c8c8362b525aaad2531591762723a@88.198.32.17:46656,b0ad03e63d49945bf794700392e9633e5a5aaa75@147.135.36.120:26656,8dc69201de98001117a88f82a22e7b1b0931c2a1@147.135.36.124:26656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$REALIO_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$REALIO_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $REALIO_GENESIS > $HOME/$REALIO_FOLDER/config/genesis.json
curl -Ls $REALIO_ADDRBOOK > $HOME/$REALIO_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${REALIO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${REALIO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${REALIO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${REALIO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${REALIO_PORT}660\"%" $HOME/$REALIO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${REALIO_PORT}317\"%; s%^address = \":8080\"%address = \":${REALIO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${REALIO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${REALIO_PORT}091\"%" $HOME/$REALIO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$REALIO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$REALIO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$REALIO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$REALIO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$REALIO_DENOM\"/" $HOME/$REALIO_FOLDER/config/app.toml

$REALIO tendermint unsafe-reset-all --home $HOME/$REALIO_FOLDER --keep-addr-book

# Create Service
sudo tee /etc/systemd/system/$REALIO.service > /dev/null << EOF
[Unit]
Description=$REALIO
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $REALIO) start --home $HOME/$REALIO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $REALIO
sudo systemctl start $REALIO

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $REALIO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${REALIO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
