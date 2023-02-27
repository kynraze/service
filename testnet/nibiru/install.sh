#
echo -e "\033[0;31m"
echo "@@@@@@@@  @@@  @@@   @@@@@@   @@@@@@@   @@@@@@@@  @@@  @@@"
echo "@@@@@@@@  @@@@ @@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@  @@@"
echo "@@!       @@!@!@@@  @@!  @@@  @@!  @@@  @@!       @@!  !@@"
echo "!@!       !@!!@!@!  !@!  @!@  !@!  @!@  !@!       !@!  @!!"
echo "@!!!:!    @!@ !!@!  @!@  !@!  @!@  !@!  @!!!:!     !@@!@! "
echo "!!!!!:    !@!  !!!  !@!  !!!  !@!  !!!  !!!!!:      @!!!  "
echo "!!:       !!:  !!!  !!:  !!!  !!:  !!!  !!:        !: :!! "
echo ":!:       :!:  !:!  :!:  !:!  :!:  !:!  :!:       :!:  !:!"
echo " :: ::::   ::   ::  ::::: ::   :::: ::   :: ::::   ::  :::"
echo ": :: ::   ::    :    : :  :   :: :  :   : :: ::    :   :: "
echo "Auto Installer For Nibiru Itn-1";
echo -e "\e[0m"
sleep 1

# Variable
NIB_WALLET=wallet
NIB=nibid
NIB_ID=nibiru-itn-1
NIB_FOLDER=.nibid
NIB_VER=v1.0.0-rc0
NIB_REPO=https://github.com/KYVENetwork/chain
NIB_GENESIS=https://raw.githubusercontent.com/enodex/service/main/testnet/nibiru/genesis.json
NIB_ADDRBOOK=https://raw.githubusercontent.com/enodex/service/main/testnet/nibiru/addrbook.json
NIB_DENOM=unibi
NIB_PORT=12

echo "export KYVE_WALLET=${NIB_WALLET}" >> $HOME/.bash_profile
echo "export KYVE=${NIB}" >> $HOME/.bash_profile
echo "export KYVE_ID=${NIB_ID}" >> $HOME/.bash_profile
echo "export KYVE_FOLDER=${NIB_FOLDER}" >> $HOME/.bash_profile
echo "export KYVE_VER=${NIB_VER}" >> $HOME/.bash_profile
echo "export KYVE_REPO=${NIB_REPO}" >> $HOME/.bash_profile
echo "export KYVE_GENESIS=${NIB_GENESIS}" >> $HOME/.bash_profile
echo "export KYVE_ADDRBOOK=${NIB_ADDRBOOK}" >> $HOME/.bash_profile
echo "export KYVE_DENOM=${NIB_DENOM}" >> $HOME/.bash_profile
echo "export KYVE_PORT=${NIB_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NIB_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " NIB_NODENAME
        echo 'export ORDOS_NODENAME='$NIB_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$NIB_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$NIB_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$NIB_PORT\e[0m"
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

# Get testnet version of Nibiru
curl -s https://get.nibiru.fi/@v0.19.2! | bash

# Init generation
$NIB config chain-id $NIB_ID
$NIB config keyring-backend file
$NIB config node tcp://localhost:${NIB_PORT}657
$NIB init $NIB_NODENAME --chain-id $NIB_ID

# Set peers and seeds
PEERS=""
sed -i 's|seeds =.*|seeds = "'$(curl -s https://networks.itn.nibiru.fi/$NIB_ID/seeds)'"|g' $HOME/.nibid/config/config.toml

# Download genesis and addrbook
curl -Ls $NIB_GENESIS > $HOME/$NIB_FOLDER/config/genesis.json
curl -Ls $NIB_ADDRBOOK > $HOME/$NIB_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NIB_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NIB_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NIB_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NIB_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NIB_PORT}660\"%" $HOME/$NIB_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NIB_PORT}317\"%; s%^address = \":8080\"%address = \":${NIB_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NIB_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NIB_PORT}091\"%" $HOME/$NIB_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$NIB_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$NIB_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$NIB_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$NIB_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025$NIB_DENOM\"/" $HOME/$NIB_FOLDER/config/app.toml


# Create Service
sudo tee /etc/systemd/system/$NIB.service > /dev/null <<EOF
[Unit]
Description=$NIB
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $NIB) start --home $HOME/$NIB_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $NIB
sudo systemctl start $NIB

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $NIB -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${NIB_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
