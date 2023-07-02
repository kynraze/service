#
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
echo "Auto Installer For Planq Network";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
PLANQ_WALLET=wallet
PLANQ=planqd
PLANQ_ID=planq_7070-2
PLANQ_FOLDER=.planqd
PLANQ_VER=v1.0.7
PLANQ_REPO=https://github.com/planq-network/planq.git
PLANQ_GENESIS=https://raw.githubusercontent.com/planq-network/networks/main/mainnet/genesis.json
PLANQ_ADDRBOOK=https://snapshots.nodestake.top/planq/Addrbook.json
PLANQ_DENOM=aplanq
PLANQ_PORT=13

echo "export PLANQ_WALLET=${PLANQ_WALLET}" >> $HOME/.bash_profile
echo "export PLANQ=${PLANQ}" >> $HOME/.bash_profile
echo "export PLANQ_ID=${PLANQ_ID}" >> $HOME/.bash_profile
echo "export PLANQ_FOLDER=${PLANQ_FOLDER}" >> $HOME/.bash_profile
echo "export PLANQ_VER=${PLANQ_VER}" >> $HOME/.bash_profile
echo "export PLANQ_REPO=${PLANQ_REPO}" >> $HOME/.bash_profile
echo "export PLANQ_GENESIS=${PLANQ_GENESIS}" >> $HOME/.bash_profile
echo "export PLANQ_ADDRBOOK=${PLANQ_ADDRBOOK}" >> $HOME/.bash_profile
echo "export PLANQ_DENOM=${PLANQ_DENOM}" >> $HOME/.bash_profile
echo "export PLANQ_PORT=${PLANQ_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $PLANQ_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " PLANQ_NODENAME
        echo 'export PLANQ_NODENAME='$PLANQ_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$PLANQ_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$PLANQ_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$PLANQ_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$PLANQ\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$PLANQ_DENOM\e[0m"
echo -e "NODE VERSION   : \033[38;2;4;204;255m$PLANQ_VER\e[0m"
echo -e "FOLDER         : \033[38;2;4;204;255m$PLANQ_FOLDER\e[0m"
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
rm -rf planq
git clone $PLANQ_REPO
cd 
git checkout $PLANQ_VER
make install

# Init generation
$PLANQ config chain-id $PLANQ_ID
$PLANQ config keyring-backend file
$PLANQ config node tcp://localhost:${PLANQ_PORT}657
$PLANQ init $PLANQ_NODENAME --chain-id $PLANQ_ID

# Set peers and seeds
PEERS="0e4cb1c58cfe909c3026466c5679e2ec2d8502ce@188.166.246.4:26656,8e1202c7a7df0fcef04a2cb348206a0efacceb26@165.22.223.88:26656,2e25e5ae74438afd464b0d9bec9aceff2c684b5f@159.223.93.59:60656,67109f02215f3fba727a6acee3547b14728a0931@45.134.226.15:60656,eb93bbbff168f16993da2c618c3ac6cebb09f9dd@184.174.35.79:26656,00eb42f518f26dd6411127c8921b3bd71b8de63b@65.108.194.44:29656,39b5ca507ea99e5b87ef9b9ad747363615534248@65.109.116.204:10256,664ae8e79d04639b07f1dbf175746d55556cc4d8@167.235.11.96:26656,60f08950193f5726070ad302a52d862b6606f8fe@157.90.151.218:26656,599baf73a8d8ae930e5ede9aa5bd92833fbd718c@51.159.213.195:26656,e7a2929fa8273d0aa0a83b2a25ad4fbdf4471558@212.227.73.190:29656,b95f231726d7ea85d7d000fa6a96b5118aa5f04a@23.106.238.167:27656,73976311b474c1e370519a4984e4cc83bdb3fc9b@165.232.182.210:18656,1eb933fb4aad816e8aef62984c670ad3ee9f55fc@147.182.238.59:33656,36243de872ba916aa75c7ffac0f39098b5535fea@85.214.33.202:33656,b5b464cfa793592d61cbc57b78087f14e7636456@38.242.229.150:26656,2a916076b4dbc935462752826a0046d011b256d2@146.190.128.182:44656,c9f03313b8ba3119f7afab57903c762dcc4e65ad@178.18.250.164:18656,bef7b04b3f7d62f0ffac5ac118b57084d0a3e168@65.109.111.204:27656,14dc39824338b18cf6fa157e518cb74941c38866@45.84.138.246:14656,1a1785bf66f47a2eff058fe770be6b6b1b694400@38.242.148.96:27656,257c511a97becad1841aa3e2ba0f1c1f4d3617e7@146.190.114.202:44656,3fd002790baf7913921903b8c0b27f217088144f@185.190.140.93:14656,f11cbfc92e2597083cfc3a5d310271258049f5a9@168.119.106.220:26656,6baa7117f17f8e6ca01fa2c247318a498b0025c3@38.242.155.79:14656,3eb12284b7fb707490b8adfda6fa7d94e2fa5cd9@94.130.54.253:16603,dd2f0ceaa0b21491ecae17413b242d69916550ae@135.125.247.70:26656,97c53c39bb622da97a3aa4ab8cc6db32e67d6e8f@146.59.110.50:26656,8277198deb91f84db25ebf60dd70a837e352220a@89.117.59.238:18656,56f473a809cb87eaee37d9346a006e0b13077c50@51.195.63.229:26656,81681e3e81c1437a404a99aa13cb946d413c018b@65.109.69.240:14656,c6093258eaf65c1c05d16494f2cb204b7eab3404@128.199.144.209:60656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$PLANQ_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$PLANQ_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $PLANQ_GENESIS > $HOME/$PLANQ_FOLDER/config/genesis.json
curl -Ls $PLANQ_ADDRBOOK > $HOME/$PLANQ_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PLANQ_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PLANQ_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PLANQ_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PLANQ_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PLANQ_PORT}660\"%" $HOME/$PLANQ_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PLANQ_PORT}317\"%; s%^address = \":8080\"%address = \":${PLANQ_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PLANQ_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PLANQ_PORT}091\"%" $HOME/$PLANQ_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$PLANQ_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$PLANQ_DENOM\"/" $HOME/$PLANQ_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$PLANQ_FOLDER/config/app.toml

$PLANQ tendermint unsafe-reset-all --home $HOME/$PLANQ_FOLDER --keep-addr-book

# Create Service
sudo tee /etc/systemd/system/$PLANQ.service > /dev/null << EOF
[Unit]
Description=$PLANQ
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $PLANQ) start --home $HOME/$PLANQ_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $PLANQ
sudo systemctl start $PLANQ

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $PLANQ -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${PLANQ_PORT}657/status | jq .result.sync_info\e[0m"
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
