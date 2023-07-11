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
echo "Auto Installer For LumenX";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
LUMENX_WALLET=wallet
LUMENX=lumenxd
LUMENX_ID=LumenX
LUMENX_FOLDER=.lumenx
LUMENX_VER=v1.4.0
LUMENX_REPO=https://github.com/cryptonetD/lumenx.git
LUMENX_GENESIS=https://raw.githubusercontent.com/cryptonetD/lumenx/master/config/genesis.json
LUMENX_ADDRBOOK=https://snap.kynraze.com/lumenx/addrbook.json
LUMENX_DENOM=ulumen
LUMENX_PORT=
LUMENX_EXPONENT=6

# Set Vars
if [ ! $LUMENX_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " LUMENX_NODENAME
fi
if [ ! $LUMENX_PORT ]; then
        read -p "[ENTER YOUR PORT] > " LUMENX_PORT
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$LUMENX_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$LUMENX_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$LUMENX_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$LUMENX\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$LUMENX_DENOM\e[0m"
echo -e "NODE VERSION   : \033[38;2;4;204;255m$LUMENX_VER\e[0m"
echo -e "FOLDER         : \033[38;2;4;204;255m$LUMENX_FOLDER\e[0m"
echo -e "EXPONENT       : \033[38;2;4;204;255m$LUMENX_EXPONENT\e[0m"
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

# Function to handle Go version error
handle_go_version_error() {
  error_message=$1
  regex='Go version ([0-9]+\.[0-9]+) is required'
  if [[ $error_message =~ $regex ]]; then
    required_go_version=${BASH_REMATCH[1]}
    echo "Required Go version: $required_go_version"
    
    # Install required Go version
    echo "Installing Go version $required_go_version..."
    wget "https://golang.org/dl/go$required_go_version.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$required_go_version.linux-amd64.tar.gz"
    rm "go$required_go_version.linux-amd64.tar.gz"
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
    source ~/.bash_profile
    go version
    
    # Retry make install
    echo "Retrying make install..."
    make install
  else
    echo "Error: Failed to extract Go version from error message."
    echo "Please manually install the required Go version."
  fi
}

# ...

# Get Repo And Install
cd $HOME
rm -rf lumenx
git clone $LUMENX_REPO
cd lumenx
git checkout $LUMENX_VER
make install || handle_go_version_error "$(make install 2>&1 | head -n 1)"

# Init generation
$LUMENX config chain-id $LUMENX_ID
$LUMENX config keyring-backend file
$LUMENX config node tcp://localhost:${LUMENX_PORT}657
$LUMENX init $LUMENX_NODENAME --chain-id $LUMENX_ID

# Set peers and seeds
PEERS="05e152f7c9fcf5448bf56cd5b850b97145a2e375@192.99.5.188:tcp://0.0.0.0:26666,e3989262b8dff3596f3b1d5e44372e9326362552@192.99.4.66:tcp://0.0.0.0:26666,43c4eb952a35df720f2cb4b86a73b43f682d6cb1@37.187.149.93:tcp://0.0.0.0:26696,cd6febf26168c82df99c8209ee82fecbb21ccfff@5.9.61.78:tcp://0.0.0.0:56656,8c1dac06d455b5895f6d90d879b03449cdc14a41@194.163.167.138:tcp://0.0.0.0:58656,dc32e90bf2321b220bc2346fa01425117372107a@65.108.232.168:tcp://0.0.0.0:22656,3c7c6c284806053c21b0e0dbfd3ca59797eab1d7@65.108.7.44:tcp://0.0.0.0:51656,60e1b660eab0c9190d9937d9828c0007b78c3284@65.109.99.212:tcp://0.0.0.0:14656,2e8e6f4754f33f93ad7c9d5de7f51c4bf181c4d8@46.38.232.86:tcp://0.0.0.0:22656,b9aee01d4a878d0cf6beff20cabc9d4659cdd441@65.108.44.100:tcp://0.0.0.0:27656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$LUMENX_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$LUMENX_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $LUMENX_GENESIS > $HOME/$LUMENX_FOLDER/config/genesis.json
curl -Ls $LUMENX_ADDRBOOK > $HOME/$LUMENX_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${LUMENX_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${LUMENX_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${LUMENX_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${LUMENX_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${LUMENX_PORT}660\"%" $HOME/$LUMENX_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${LUMENX_PORT}317\"%; s%^address = \":8080\"%address = \":${LUMENX_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${LUMENX_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${LUMENX_PORT}091\"%" $HOME/$LUMENX_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$LUMENX_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$LUMENX_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$LUMENX_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$LUMENX_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$LUMENX_DENOM\"/" $HOME/$LUMENX_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$LUMENX_FOLDER/config/app.toml

$LUMENX tendermint unsafe-reset-all --home $HOME/$LUMENX_FOLDER --keep-addr-book

# Create Service
sudo tee /etc/systemd/system/$LUMENX.service > /dev/null << EOF
[Unit]
Description=$LUMENX
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $LUMENX) start --home $HOME/$LUMENX_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $LUMENX
sudo systemctl start $LUMENX

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $LUMENX -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${LUMENX_PORT}657/status | jq .result.sync_info\e[0m"
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
