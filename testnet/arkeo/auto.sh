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
echo "Auto Installer For Arkeo Network";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
ARKEO_WALLET=wallet
ARKEO=arkeod
ARKEO_ID=arkeo
ARKEO_FOLDER=.arkeo
ARKEO_VER=1
ARKEO_REPO=https://snap.kynraze.com/test/arkeo/arkeod
ARKEO_GENESIS=https://raw.githubusercontent.com/kynraze/service/main/testnet/arkeo/genesis.json
ARKEO_ADDRBOOK=https://snap.kynraze.com/test/arkeo/addrbook.json
ARKEO_DENOM=uarkeo
ARKEO_PORT=
ARKEO_EXPONENT=6

# Set Vars
        read -p "[ENTER YOUR NODE] > " ARKEO_NODENAME
        read -p "[ENTER YOUR PORT] > (Recommendation: Two digits or more) " ARKEO_PORT
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$ARKEO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$ARKEO_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$ARKEO_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$ARKEO\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$ARKEO_DENOM\e[0m"
echo -e "NODE VERSION   : \033[38;2;4;204;255m$ARKEO_VER\e[0m"
echo -e "FOLDER         : \033[38;2;4;204;255m$ARKEO_FOLDER\e[0m"
echo -e "EXPONENT       : \033[38;2;4;204;255m$ARKEO_EXPONENT\e[0m"
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
arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
  go_pkg="go$ver.linux-amd64.tar.gz"
elif [ "$arch" = "aarch64" ]; then
  go_pkg="go$ver.linux-arm64.tar.gz"
else
  echo "Unsupported system architecture: $arch"
  exit 1
fi

cd $HOME
wget "https://golang.org/dl/$go_pkg"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$go_pkg"
rm "$go_pkg"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get Repo And Install
wget https://snap.kynraze.com/test/arkeo/arkeod
chmod +x arkeod
mv arkeod $HOME/go/bin/

# Init generation
$ARKEO config chain-id $ARKEO_ID
$ARKEO config keyring-backend file
$ARKEO config node tcp://localhost:${ARKEO_PORT}657
$ARKEO init $ARKEO_NODENAME --chain-id $ARKEO_ID

# Set peers and seeds
PEERS="ed6dc23dd027cb0a248abdcad11dd11f3f10fce6@seed.arkeo.network:26656,727929c73968e07bf7a29c91d64eb3fab7269ee8@192.99.160.197:27656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$ARKEO_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$ARKEO_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $ARKEO_GENESIS > $HOME/$ARKEO_FOLDER/config/genesis.json
curl -Ls $ARKEO_ADDRBOOK > $HOME/$ARKEO_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ARKEO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ARKEO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ARKEO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ARKEO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ARKEO_PORT}660\"%" $HOME/$ARKEO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ARKEO_PORT}317\"%; s%^address = \":8080\"%address = \":${ARKEO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ARKEO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ARKEO_PORT}091\"%" $HOME/$ARKEO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ARKEO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ARKEO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ARKEO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ARKEO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$ARKEO_DENOM\"/" $HOME/$ARKEO_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$ARKEO_FOLDER/config/app.toml

$ARKEO tendermint unsafe-reset-all --home $HOME/$ARKEO_FOLDER --keep-addr-book

# Create Service
sudo tee /etc/systemd/system/$ARKEO.service > /dev/null << EOF
[Unit]
Description=$ARKEO
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $ARKEO) start --home $HOME/$ARKEO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ARKEO
sudo systemctl start $ARKEO

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $ARKEO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${ARKEO_PORT}657/status | jq .result.sync_info\e[0m"
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
