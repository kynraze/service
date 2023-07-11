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
echo "Auto Installer For Kyve Network";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
KYVE_WALLET=wallet
KYVE=kyved
KYVE_ID=kyve-1
KYVE_FOLDER=.kyve
KYVE_VER=v1.2.2
KYVE_REPO=https://github.com/KYVENetwork/chain.git
KYVE_GENESIS=https://files.kyve.network/mainnet/genesis.json
KYVE_ADDRBOOK=https://raw.githubusercontent.com/kynraze/service/main/mainnet/kyve/addrbook.json
KYVE_DENOM=ukyve
KYVE_PORT=
KYVE_EXPONENT=6

# Set Vars
if [ ! $KYVE_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " KYVE_NODENAME
fi
if [ ! $KYVE_PORT ]; then
        read -p "[ENTER YOUR PORT] > " KYVE_PORT
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$KYVE_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$KYVE_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$KYVE_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$KYVE\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$KYVE_DENOM\e[0m"
echo -e "NODE VERSION   : \033[38;2;4;204;255m$KYVE_VER\e[0m"
echo -e "FOLDER         : \033[38;2;4;204;255m$KYVE_FOLDER\e[0m"
echo -e "EXPONENT       : \033[38;2;4;204;255m$KYVE_EXPONENT\e[0m"
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
rm -rf aura
git clone $KYVE_REPO
cd aura
git checkout $KYVE_VER
make install || handle_go_version_error "$(make install 2>&1 | head -n 1)"

# Init generation
$KYVE config chain-id $KYVE_ID
$KYVE config keyring-backend file
$KYVE config node tcp://localhost:${KYVE_PORT}657
$KYVE init $KYVE_NODENAME --chain-id $KYVE_ID

# Set peers and seeds
PEERS="ebc272824924ea1a27ea3183dd0b9ba713494f83@95.214.52.139:95.214.52.139:27246,5ce11995f9cc12a7a9d4370a7a1caeb37bfe24ca@35.161.244.76:35.161.244.76:26656,eb8db7e385385582544b52d6c5417938da4048a4@45.77.249.228:tcp://0.0.0.0:26656,b950b6b08f7a6d5c3e068fcd263802b336ffe047@18.198.182.214:18.198.182.214:26656,abd78598669172e674b5fa93be48c8bde6361c5e@146.59.85.223:146.59.85.223:11056,fae8cd5f04406e64484a7a8b6719eacbb861c094@44.241.103.199:44.241.103.199:26656,146d27829fd240e0e4672700514e9835cb6fdd98@34.212.201.1:34.212.201.1:26656,cca92eeb43850b9572025da5ecaae6e4703925e2@185.172.191.11:185.172.191.11:26656,3ba99131fb318a7b0633855b1087e9c320fb0ac0@116.203.188.45:tcp://0.0.0.0:26656,53cf43a498af05bef6a907a455a2bf19c92631ec@65.108.124.219:65.108.124.219:42656,61a30f8791ac108a92e425b4ec461e7a1904b829@65.109.92.148:tcp://0.0.0.0:27656,d3ab21eb8396d5c07f14bc9c981a3f98c19d9006@5.75.167.92:tcp://0.0.0.0:26656,d3f68d482f5c5fdabf4c2acb90692d5baaa0b1e6@65.109.116.21:65.109.116.21:11124,9a54ab78dac8c2942bc3af7ecce575cbb2008df1@34.88.213.228:tcp://104.196.101.86:26656,49b57d57ecdff3aa62791565f09b05f9a0b2acc9@167.99.141.216:tcp://0.0.0.0:26656,9e76699be460f8d169671aa8689094b9ce3a090b@95.214.55.100:95.214.55.100:26356,58a0a1a012ac8acbbaaaa27d90ed9b081ac7c075@3.139.238.196:3.139.238.196:31305,03c6bd8a00ff0298147163320d07c0f8da565739@116.203.137.24:tcp://0.0.0.0:26656,761f89f03b0b83009525e39a8c27e700df7cc62d@3.137.180.18:3.137.180.18:31308,6c15e6f7d0077a7647a8bc65f3e44244e35cbf6d@57.128.20.238:tcp://0.0.0.0:26656,3cb5bbe5550d6c5357b938f8e39bc366040f5a8a@45.79.182.25:45.79.182.25:26656,d6fd05c21c568cc9fa21a97fe45d2bc1ca7d503e@195.189.96.106:tcp://195.189.96.106:39656,307f4024107ef114dba355fe97dab44b8b45cefc@38.242.253.58:38.242.253.58:29656,101449741140e58c411880f14f78b49f0de93bf5@65.109.94.221:65.109.94.221:37656,4a4f9cebb22a92cdc5b5a2d5239bab6166cb9943@185.144.99.32:185.144.99.32:26656,39392cf41c1d7ae8f98b6efaa740dc4abe3002ff@65.109.92.241:65.109.92.241:20656,e2e261b9d2baae9ddacc4019b1b7935b2b9c74aa@65.109.29.224:65.109.29.224:27656,2d3b8fa61527f272f811fdaa7fbf72a414394351@104.196.101.86:tcp://104.196.101.86:26656,64e89419e55dd5acd3c80fe0d6cee42fa42919a1@52.68.114.1:52.68.114.1:26656,d1014d85807b986ea8dabc5ab3eb37845f6864c3@65.108.70.119:65.108.70.119:43656,16c544e6ea0496a8e8d02234a7704592c8df8ba4@65.108.128.240:tcp://0.0.0.0:26656,0fe8e7419225639ec2775e52952dfe74534275c5@135.181.215.62:tcp://0.0.0.0:4640,357fad204f2d156e90d0fb479b9c64e89122af46@65.21.193.117:tcp://0.0.0.0:3640,0ca2c8345a4e58474741466d0ea37d1881ec0aaf@162.55.234.70:162.55.234.70:49656,5fe1b0b1b081e1c769a27277bf934010f0a5ec4f@116.203.179.225:tcp://0.0.0.0:26656,3b7f7ce13b56059c140defb94b6e24a7b1b5707b@5.78.67.118:5.78.67.118:26656,ab43b03e07fcd053d0bad25771d8e8bbba1ae3c7@81.17.60.127:tcp://0.0.0.0:26656,a0ba3bd9616b51c26ab6ecc49a30a13d0438ab7f@65.109.94.250:65.109.94.250:28656,b621b236b4c5c78c23d0a49c661bec7cd6d7450c@95.216.164.26:tcp://0.0.0.0:24656,dc56abb8aa8905eb9d8cfdf367fef6425402d4e7@57.128.20.184:tcp://57.128.20.184:39656,60f3420269c4c3f369e468b4e7bf147dd9376734@65.108.71.92:65.108.71.92:49656,e23311fce57e1fafa6672275fa1b390fe3860808@162.19.138.20:tcp://0.0.0.0:36656,24bada9e5a643fe9b9a35a1a27226e2a8785fa94@89.163.157.64:89.163.157.64:26656,9b2e7166012c33e43925350315d02dc0eaeb4145@185.246.84.59:tcp://0.0.0.0:3640,3bb0cb5f1772b416de1b8eef3382fd2848cfa133@52.68.93.240:52.68.93.240:26656,55ba1007ce5c4c68bf646e3b3027752240c14da9@78.47.117.108:tcp://0.0.0.0:26656,0ab23bfd2924c09a0cb2166a78e65d6d0fbd172a@57.128.162.152:57.128.162.152:26656,1642aa9f93731e541469f9a713d4c632cf687a25@3.72.28.238:3.72.28.238:26656,41caa4106f68977e3a5123e56f57934a2d34a1c1@95.214.53.217:95.214.53.217:27246,443f41172aafaa6c711333c621e019fde3f0ba99@5.75.144.137:tcp://0.0.0.0:26656,4899b6be23b97ff0609bad11125654e2dab5ba9c@18.196.127.224:18.196.127.224:26656,42cb3ae7c2ecf81964ebac1b2081397d24b79df4@65.108.238.102:65.108.238.102:11056"
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
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$KYVE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$KYVE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$KYVE_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$KYVE_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$KYVE_DENOM\"/" $HOME/$KYVE_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$KYVE_FOLDER/config/app.toml

$KYVE tendermint unsafe-reset-all --home $HOME/$KYVE_FOLDER --keep-addr-book

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

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $KYVE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${KYVE_PORT}657/status | jq .result.sync_info\e[0m"
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
