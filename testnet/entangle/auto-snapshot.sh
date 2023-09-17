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
echo "Auto Installer For Entangle";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
ENTANGLE_WALLET=wallet
ENTANGLE=entangled
ENTANGLE_ID=entangle_33133-1
ENTANGLE_FOLDER=.entangled
ENTANGLE_VER=v1.0.1
ENTANGLE_REPO=https://github.com/Entangle-Protocol/entangle-blockchain.git
ENTANGLE_GENESIS=https://raw.githubusercontent.com/kynraze/service/main/testnet/entangle/genesis.json
ENTANGLE_ADDRBOOK=https://snap.kynraze.com/test/entangle/addrbook.json
ENTANGLE_DENOM=aNGL
ENTANGLE_PORT=
ENTANGLE_URL=https://snap.kynraze.com/test/entangle/snapshot-latest.tar.lz4
ENTANGLE_EXPONENT=18

# Set Vars
        read -p "[ENTER YOUR NODE] > " ENTANGLE_NODENAME
        read -p "[ENTER YOUR PORT] > (Recommendation: Two digits or more) " ENTANGLE_PORT
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$ENTANGLE_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$ENTANGLE_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$ENTANGLE_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$ENTANGLE\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$ENTANGLE_DENOM\e[0m"
echo -e "NODE VERSION   : \033[38;2;4;204;255m$ENTANGLE_VER\e[0m"
echo -e "FOLDER         : \033[38;2;4;204;255m$ENTANGLE_FOLDER\e[0m"
echo -e "EXPONENT       : \033[38;2;4;204;255m$ENTANGLE_EXPONENT\e[0m"
echo -e "SNAPSHOT URL   : \033[38;2;4;204;255m$ENTANGLE_URL\e[0m"
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

# Function to handle Go version error
handle_go_version_error() {
  error_message=$1
  regex='Go version ([0-9]+\.[0-9]+) is required'
  if [[ $error_message =~ $regex ]]; then
    required_go_version=${BASH_REMATCH[1]}
    echo "Required Go version: $required_go_version"

    # Install required Go version
    arch=$(uname -m) 
    if [ "$arch" = "x86_64" ]; then
      go_pkg="go$required_go_version.linux-amd64.tar.gz"
    elif [ "$arch" = "aarch64" ]; then
     go_pkg="go$required_go_version.linux-arm64.tar.gz"
    else
      echo "Unsupported system architecture: $arch"
      exit 1
    fi

    wget "https://golang.org/dl/$go_pkg"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$go_pkg"
    rm "$go_pkg"
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

# Get Repo And Install
cd $HOME
rm -rf entangle-blockchain
git clone $ENTANGLE_REPO
cd entangle-blockchain
make install || handle_go_version_error "$(make install 2>&1 | head -n 1)"

# Init generation
$ENTANGLE config chain-id $ENTANGLE_ID
$ENTANGLE config keyring-backend file
$ENTANGLE config node tcp://localhost:${ENTANGLE_PORT}657
$ENTANGLE init $ENTANGLE_NODENAME --chain-id $ENTANGLE_ID

# Set peers and seeds
PEERS=25b17c1c465b4fd30212a57cad5c37a426185944@15.235.45.89:26656,dc4114a506b48ab062b0782a410d5618a22fafb7@18.207.195.188:26656,07577d39b32ecb7f8bd4a92cc9b03d4048758027@91.229.245.140:26656,7778929fed4ca3c0b99d3b0079cbdae51cb93359@65.109.154.182:16656,7afbc1c83b9a116223a4417bfc429ea1073be5ca@65.109.154.181:16656,263b106f9755656ac18594cb951754187f3d51ba@65.109.85.170:42626,f8119b27e7744d36ad1e59736b2488683be0aa3b@3.87.189.254:26656,80165713358209889ea25eecfcb245aaf09be1f0@34.66.181.145:30656,ab494f0671504ec83bbf418c286130f8c57f3e35@45.67.217.11:26656,f97c0b5b018288295f158ddb43acaaf8871102d4@136.243.105.186:11656,627bd0f5b91367c00bb4125e278108c60534ba4a@94.130.220.233:20656
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$ENTANGLE_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$ENTANGLE_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $ENTANGLE_GENESIS > $HOME/$ENTANGLE_FOLDER/config/genesis.json
curl -Ls $ENTANGLE_ADDRBOOK > $HOME/$ENTANGLE_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ENTANGLE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ENTANGLE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ENTANGLE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ENTANGLE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ENTANGLE_PORT}660\"%" $HOME/$ENTANGLE_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ENTANGLE_PORT}317\"%; s%^address = \":8080\"%address = \":${ENTANGLE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ENTANGLE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ENTANGLE_PORT}091\"%" $HOME/$ENTANGLE_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ENTANGLE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ENTANGLE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ENTANGLE_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ENTANGLE_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$ENTANGLE_DENOM\"/" $HOME/$ENTANGLE_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$ENTANGLE_FOLDER/config/app.toml

$ENTANGLE tendermint unsafe-reset-all --home $HOME/$ENTANGLE_FOLDER --keep-addr-book

curl -L $ENTANGLE_URL | tar -Ilz4 -xf - -C $HOME/$ENTANGLE_FOLDER

# Create Service
sudo tee /etc/systemd/system/$ENTANGLE.service > /dev/null << EOF
[Unit]
Description=$ENTANGLE
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $ENTANGLE) start --home $HOME/$ENTANGLE_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ENTANGLE
sudo systemctl start $ENTANGLE

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $ENTANGLE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${ENTANGLE_PORT}657/status | jq .result.sync_info\e[0m"
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
