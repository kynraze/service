#
echo -e "\033[38;2;4;204;255m"
echo "======================================================================"
echo "██╗  ██╗██╗   ██╗███╗   ██╗██████╗  █████╗ ███████╗███████╗"
echo "██║ ██╔╝╚██╗ ██╔╝████╗  ██║██╔══██╗██╔══██╗╚══███╔╝██╔════╝"
echo "█████╔╝  ╚████╔╝ ██╔██╗ ██║██████╔╝███████║  ███╔╝ █████╗  "
echo "██╔═██╗   ╚██╔╝  ██║╚██╗██║██╔══██╗██╔══██║ ███╔╝  ██╔══╝  "
echo "██║  ██╗   ██║   ██║ ╚████║██║  ██║██║  ██║███████╗███████╗"
echo "╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝"
echo "======================================================================"
echo "Auto Installer For Bonus Block";
echo -e "\e[0m"
sleep 1

# Variable
BONUS_WALLET=wallet
BONUS=bonus-blockd
BONUS_ID=blocktopia-01
BONUS_FOLDER=.bonusblock
BONUS_VER=
BONUS_REPO=https://github.com/BBlockLabs/BonusBlock-chain
BONUS_GENESIS=https://raw.githubusercontent.com/kynraze/service/main/testnet/bonus/genesis.json
BONUS_ADDRBOOK=https://raw.githubusercontent.com/elangrr/testnet_guide/main/services/addrbook/bonusblock/addrbook.json
BONUS_DENOM=ubonus
BONUS_PORT=30

echo "export BONUS_WALLET=${BONUS_WALLET}" >> $HOME/.bash_profile
echo "export BONUS=${BONUS}" >> $HOME/.bash_profile
echo "export BONUS_ID=${BONUS_ID}" >> $HOME/.bash_profile
echo "export BONUS_FOLDER=${BONUS_FOLDER}" >> $HOME/.bash_profile
echo "export BONUS_VER=${BONUS_VER}" >> $HOME/.bash_profile
echo "export BONUS_REPO=${BONUS_REPO}" >> $HOME/.bash_profile
echo "export BONUS_GENESIS=${BONUS_GENESIS}" >> $HOME/.bash_profile
echo "export BONUS_ADDRBOOK=${BONUS_ADDRBOOK}" >> $HOME/.bash_profile
echo "export BONUS_DENOM=${BONUS_DENOM}" >> $HOME/.bash_profile
echo "export BONUS_PORT=${BONUS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $BONUS_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " BONUS_NODENAME
        echo 'export BONUS_NODENAME='$BONUS_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$BONUS_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$BONUS_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$BONUS_PORT\e[0m"
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

# Get Repo And Install
cd $HOME
rm -rf BonusBlock-chain
rm -rf $BONUS_FOLDER
git clone $BONUS_REPO
cd BonusBlock-chain
git checkout $BONUS_VER
make install

# Init generation
$BONUS config chain-id $BONUS_ID
$BONUS config keyring-backend file
$BONUS config node tcp://localhost:${BONUS_PORT}657
$BONUS init $BONUS_NODENAME --chain-id $BONUS_ID

# Set peers and seeds
PEERS="3b565572132f95b73fe97d5cc44eaa167eb68587@139.59.145.51:18656,23214452b2d55452e0c21f1f812bc2e0440369c7@159.223.31.146:26656,23b4f038544d4fd37a5f883d44cf1488c30875ce@161.35.193.41:26656,dc6ec58d6c5424a897dcf47c254d228c8f61fe5a@164.92.91.248:26656,c5af9a1f195d054a897efe4c78f31d7a903e7033@109.123.254.127:26656,fadd863afad4803c2329609cbf91abcab203ef2c@46.101.131.222:26656,2501d22acb69740cea14a61e0a91db7b7cc618b0@65.21.232.160:32656,af191c7516f5a0a7b8c236d719529eef6399b5b0@165.232.156.214:18656,adfcc77ce1a4f9bb06bab696e413af9bd5c60e9f@178.128.82.25:26656,ac2ef5a710f9083939b18e40e00e909663acc35f@188.166.180.152:26656,aa4f63c188ad819aa156b0b51dd289d6f68230e2@143.198.136.136:18656,52ade4cf379b862ae69d0d306fb368c2f9a859ea@31.220.86.138:26656,04b47b51a8711f904e2fff57ab48147b79a8dfc5@139.144.37.19:26656,bdd6de3b14596bb77be8cb3a64831bd587b3646b@46.101.194.64:26656,3d2fffdf9d432897b85a509d9755ac01fea09f5e@78.46.61.117:13656,9a6b9a57ea0d4c97650344408f3762ca8c4ebb4a@198.199.74.16:26656,5e92b6c6fcd4c75996ec6e978c2b09c6787d5637@170.64.160.25:26656,ab49e570c68367de973f88837268c7accbf4f250@209.145.58.64:26656,20cd65dd72b625abbbb0d04ae32837328b1b979e@64.225.50.67:26656,3c4f0b727241b99cf69a845ac1ea7f62f4c07819@161.35.19.181:17656,b13dc1338c9d7d231c4a1821ae9141d1605d5ece@165.232.126.250:26656,baa4d63df7f3e3f0fa831ff3de89aca91e814a7f@103.253.145.162:26656,6a9a26e8f0e1cc8c58bfc36fa71cb71fe958131a@81.0.218.58:26656,9ca1b516be8ff6e08b72e36aa405775453fb8313@64.226.94.129:18656,bd81cca7b7f4fce6239ee1bb1c763fa4f6b36c30@84.46.246.248:26656,6c15c2de9ebc8b0879cb17524d2aa0375282762e@51.15.236.100:26656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$BONUS_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$BONUS_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $BONUS_GENESIS > $HOME/$BONUS_FOLDER/config/genesis.json
curl -Ls $BONUS_ADDRBOOK > $HOME/$BONUS_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${BONUS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${BONUS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${BONUS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${BONUS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${BONUS_PORT}660\"%" $HOME/$BONUS_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${BONUS_PORT}317\"%; s%^address = \":8080\"%address = \":${BONUS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${BONUS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${BONUS_PORT}091\"%" $HOME/$BONUS_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$BONUS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$BONUS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$BONUS_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$BONUS_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$BONUS_DENOM\"/" $HOME/$BONUS_FOLDER/config/app.toml

$BONUS tendermint unsafe-reset-all --home $HOME/$BONUS_FOLDER --keep-addr-book

STATE_SYNC_RPC="https://test-bonus-rpc.kynraze.com:443"
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/$BONUS_FOLDER/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
    $HOME/$BONUS_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  $HOME/$BONUS_FOLDER/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/$BONUS_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$BONUS.service > /dev/null << EOF
[Unit]
Description=$BONUS
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BONUS) start --home $HOME/$BONUS_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $BONUS
sudo systemctl start $BONUS

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $BONUS -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${BONUS_PORT}657/status | jq .result.sync_info\e[0m"
echo ""
source $HOME/.bash_profile
# End
