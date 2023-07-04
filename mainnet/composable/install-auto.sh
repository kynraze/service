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
echo "Auto Installer For Composable";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
COMP_WALLET=wallet
COMP=centaurid
COMP_ID=centauri-1
COMP_FOLDER=.banksy
COMP_VER=v3.2.2
COMP_REPO=https://github.com/notional-labs/composable-centauri.git
COMP_GENESIS=https://raw.githubusercontent.com/kynraze/service/main/mainnet/composable/genesis.json
COMP_ADDRBOOK=https://snap.kynraze.com/composable/addrbook.json
COMP_DENOM=ppica
COMP_PORT=15

echo "export COMP_WALLET=${COMP_WALLET}" >> $HOME/.bash_profile
echo "export COMP=${COMP}" >> $HOME/.bash_profile
echo "export COMP_ID=${COMP_ID}" >> $HOME/.bash_profile
echo "export COMP_FOLDER=${COMP_FOLDER}" >> $HOME/.bash_profile
echo "export COMP_VER=${COMP_VER}" >> $HOME/.bash_profile
echo "export COMP_REPO=${COMP_REPO}" >> $HOME/.bash_profile
echo "export COMP_GENESIS=${COMP_GENESIS}" >> $HOME/.bash_profile
echo "export COMP_ADDRBOOK=${COMP_ADDRBOOK}" >> $HOME/.bash_profile
echo "export COMP_DENOM=${COMP_DENOM}" >> $HOME/.bash_profile
echo "export COMP_PORT=${COMP_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $COMP_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " COMP_NODENAME
        echo 'export COMP_NODENAME='$COMP_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$COMP_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$COMP_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$COMP_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$COMP\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$COMP_DENOM\e[0m"
echo -e "NODE VERSION   : \033[38;2;4;204;255m$COMP_VER\e[0m"
echo -e "FOLDER         : \033[38;2;4;204;255m$COMP_FOLDER\e[0m"
echo ""
function select_action() {
  read -p "Please confirm if this configuration is correct.(Y/N): " choice
case "$choice" in
y|Y|Yes) # Execute your command here
echo "Executing command..."

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.20"
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
rm -rf composable-centauri
git clone $COMP_REPO
cd 
git checkout $COMP_VER
make install

# Init generation
$COMP config chain-id $COMP_ID
$COMP config keyring-backend file
$COMP config node tcp://localhost:${COMP_PORT}657
$COMP init $COMP_NODENAME --chain-id $COMP_ID

# Set peers and seeds
PEERS="4319824b0ff4c795ec8c48e09f504fbe97c8a6e7@142.132.135.125:20656,6f79c5379819274cd18aa09bebb9cd1046811a64@168.119.91.22:2260,4cb008db9c8ae2eb5c751006b977d6910e990c5d@65.108.71.163:2630,bf2a1219aee049de39891b4e2ce7d3624181aa64@167.235.71.89:26656,7f838c46362345257b49b3f17ba6581668c1f7cc@65.108.129.94:26656,b47ce241046fa26e09ac2da75f0a993f72e5b24c@93.190.141.68:20206,6ad7ab8f1e2e94e130315b577eff91b5dd11874c@65.109.154.181:31656,92336725dc7fda1504ea5962bb551f2610126377@65.108.198.118:22256,99e23226333f2be8cf2377060c5d0909ee077306@65.108.204.225:22256D"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$COMP_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$COMP_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $COMP_GENESIS > $HOME/$COMP_FOLDER/config/genesis.json
curl -Ls $COMP_ADDRBOOK > $HOME/$COMP_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${COMP_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${COMP_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${COMP_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${COMP_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${COMP_PORT}660\"%" $HOME/$COMP_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${COMP_PORT}317\"%; s%^address = \":8080\"%address = \":${COMP_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${COMP_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${COMP_PORT}091\"%" $HOME/$COMP_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$COMP_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$COMP_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$COMP_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$COMP_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$COMP_DENOM\"/" $HOME/$COMP_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$COMP_FOLDER/config/app.toml

$COMP tendermint unsafe-reset-all --home $HOME/$COMP_FOLDER --keep-addr-book

# Create Service
sudo tee /etc/systemd/system/$COMP.service > /dev/null << EOF
[Unit]
Description=$COMP
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $COMP) start --home $HOME/$COMP_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $COMP
sudo systemctl start $COMP

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $COMP -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${COMP_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
;;
n|N|no|No) echo "Exiting script."
   exit 0
   ;;
*)   echo "Invalid choice. Please try again."
select_action
;;
esac
}
select_action
# End
