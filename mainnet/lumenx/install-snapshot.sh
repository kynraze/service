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
echo "Auto Installer For Lumenx";
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
LUMENX_PORT=11

echo "export LUMENX_WALLET=${LUMENX_WALLET}" >> $HOME/.bash_profile
echo "export LUMENX=${LUMENX}" >> $HOME/.bash_profile
echo "export LUMENX_ID=${LUMENX_ID}" >> $HOME/.bash_profile
echo "export LUMENX_FOLDER=${LUMENX_FOLDER}" >> $HOME/.bash_profile
echo "export LUMENX_VER=${LUMENX_VER}" >> $HOME/.bash_profile
echo "export LUMENX_REPO=${LUMENX_REPO}" >> $HOME/.bash_profile
echo "export LUMENX_GENESIS=${LUMENX_GENESIS}" >> $HOME/.bash_profile
echo "export LUMENX_ADDRBOOK=${LUMENX_ADDRBOOK}" >> $HOME/.bash_profile
echo "export LUMENX_DENOM=${LUMENX_DENOM}" >> $HOME/.bash_profile
echo "export LUMENX_PORT=${LUMENX_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $LUMENX_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " LUMENX_NODENAME
        echo 'export LUMENX_NODENAME='$LUMENX_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$LUMENX_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$LUMENX_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$LUMENX_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$LUMENX\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$LUMENX_DENOM\e[0m"
echo ""
sleep 10

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
rm -rf lumenx
git clone $LUMENX_REPO
cd lumenx
git checkout $LUMENX_VER
make install

# Init generation
$LUMENX config chain-id $LUMENX_ID
$LUMENX config keyring-backend file
$LUMENX config node tcp://localhost:${LUMENX_PORT}657
$LUMENX init $LUMENX_NODENAME --chain-id $LUMENX_ID

# Set peers and seeds
PEERS="e3989262b8dff3596f3b1d5e44372e9326362552@192.99.4.66:26666,e91a86a4bec23993f584f346208e7b47285eb632@65.21.226.230:27656,899c2f0828716930483b65b3afb6ce9c7d6a3f03@65.109.154.181:17656,b9aee01d4a878d0cf6beff20cabc9d4659cdd441@65.108.44.100:27656,5ce3b6e1b59150b8910a7b9d6904526f56972120@65.109.156.208:08656,6a90fe3e6dd34768c40b5694f7bd2209ca12739f@169.0.108.149:26656,43c4eb952a35df720f2cb4b86a73b43f682d6cb1@37.187.149.93:26696,8c1dac06d455b5895f6d90d879b03449cdc14a41@194.163.167.138:58656,327dce4a8da8ba99e970f76d9520527b49c8717e@38.242.237.107:26736,64c01c609297f010790a67fbb9e339a9072aa890@144.24.134.26:26656,d6702ac9e1112dc65b1dd9443e178b18ea38c48d@185.69.166.164:26656,9a49635f0ecb7ba93fc9eba952cbe58767557010@185.215.180.70:26656,f5a517c682466dac525ce87ea9c2f2cbc8c4f002@38.242.233.215:26656,2e8e6f4754f33f93ad7c9d5de7f51c4bf181c4d8@51.89.195.66:11656,e29d17459030df3ade1c7232a570abf942d5dc3c@65.109.28.226:11656,2bb924a4a62419add0f70b7bd5684396ffaeda4d@65.109.116.204:11256,5b0954e1323cd3f46de5074a1514e8b6fe5d6c87@65.109.65.163:11256,d605a4e19a75568297220e43148aa613724091d0@213.133.103.188:13856,3c7c6c284806053c21b0e0dbfd3ca59797eab1d7@65.108.7.44:51656,c9e90a5c627f373d7602d1797b90720b0257f6f0@65.21.225.10:17656,1d94c81f6b25a51be173d22523f6267113bfcbec@45.134.226.70:26656,dc32e90bf2321b220bc2346fa01425117372107a@65.108.232.168:22656,0a5c99bb93675ba2ffee384d3aec3129e80f386f@207.154.251.199:26656,81913c271aad8b26c10e3175a8f1ecf813921bab@144.24.149.118:26656,05e152f7c9fcf5448bf56cd5b850b97145a2e375@192.99.5.188:26666,8191f08f468bb07535340f35b68764f21128b80c@46.0.203.78:23356,c3ac758bd1c0a1533c33a0cbae082f99ef8e1de8@208.64.58.50:26656"
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

curl -L https://snap.kynraze.com/lumenx/snapshot-latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$LUMENX_FOLDER

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
# End
