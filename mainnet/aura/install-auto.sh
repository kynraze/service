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
echo "Auto Installer For Aura Network";
echo "Github  : https://github.com/kynraze";
echo "Website : https://kynraze.com";
echo -e "\e[0m"
sleep 1

# Variable
AURA_WALLET=wallet
AURA=aurad
AURA_ID=xstaxy-1
AURA_FOLDER=.aura
AURA_VER=aura_v0.4.5
AURA_REPO=https://github.com/aura-nw/aura.git
AURA_GENESIS=https://raw.githubusercontent.com/kynraze/service/main/mainnet/aura/genesis.json
AURA_ADDRBOOK=https://snapshots.nodestake.top/aura/addrbook.json
AURA_DENOM=uaura
AURA_PORT=
AURA_EXPONENT=6

# Set Vars
if [ ! $AURA_NODENAME ]; then
        read -p "[ENTER YOUR NODE] > " AURA_NODENAME
fi
if [ ! $AURA_PORT ]; then
        read -p "[ENTER YOUR PORT] > " AURA_PORT
fi
echo ""
echo -e "YOUR NODE NAME : \033[38;2;4;204;255m$AURA_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \033[38;2;4;204;255m$AURA_ID\e[0m"
echo -e "NODE PORT      : \033[38;2;4;204;255m$AURA_PORT\e[0m"
echo -e "BINARY         : \033[38;2;4;204;255m$AURA\e[0m"
echo -e "DENOM          : \033[38;2;4;204;255m$AURA_DENOM\e[0m"
echo -e "NODE VERSION   : \033[38;2;4;204;255m$AURA_VER\e[0m"
echo -e "FOLDER         : \033[38;2;4;204;255m$AURA_FOLDER\e[0m"
echo -e "EXPONENT       : \033[38;2;4;204;255m$AURA_EXPONENT\e[0m"
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
rm -rf aura
git clone $AURA_REPO
cd 
git checkout $AURA_VER
make install

# Init generation
$AURA config chain-id $AURA_ID
$AURA config keyring-backend file
$AURA config node tcp://localhost:${AURA_PORT}657
$AURA init $AURA_NODENAME --chain-id $AURA_ID

# Set peers and seeds
PEERS="10b4cb9cbd7d3dae1aacc97355c1269ce5e36c57@93.190.141.68:93.190.141.68:21056,a998e8db13523309dbee7241679058747a17d37e@212.23.222.175:tcp://0.0.0.0:27656,727c59b5388754d8e6d6c5cd64a9ee2b52acf226@65.109.92.235:tcp://0.0.0.0:11086,ed68064620cebd196f56335bf801144efa9fb5ef@217.144.98.50:tcp://0.0.0.0:26656,4ebc1e89eb6d7f298b961d64594fc18a1d1b197c@57.128.22.207:tcp://0.0.0.0:15611,e3f4e77537cb2d18270982d4037e82768f7a779e@65.108.229.102:tcp://0.0.0.0:36656,0b8bd8c1b956b441f036e71df3a4d96e85f843b8@13.250.159.219:tcp://0.0.0.0:26656,9c8c5eb0c2015051572dddb3eb5ed1b4a100419c@51.195.61.86:tcp://0.0.0.0:26656,b5774014ea48bee11fede34398118f98215508f0@141.95.148.107:tcp://0.0.0.0:26656,d2ea7c421c8bb552b84eba4c7924f9e78d3a79ae@176.9.158.219:tcp://0.0.0.0:41256,c0c33d6f9e4868f5a40f3ccb9f638fbd215d8874@188.165.200.129:tcp://0.0.0.0:11756,2b837edb779038f29785b347fb78397ab7dec3bf@148.251.88.145:tcp://0.0.0.0:10456,abb367c73ef28fc90f5071e1258a23c0e5be17cd@103.107.183.89:103.107.183.89:26656,22af8298e37e0225bdbbc3b85f62a02941a11003@159.148.146.132:tcp://0.0.0.0:26656,e46238ddcf2113b70f59b417994c375e2d67e265@71.236.119.108:71.236.119.108:40656,c9c0b28dcf2db5f0e7b756986d3326d62ba47e78@144.126.147.58:144.126.147.58:26656,a19b89ebbf7331f435b8ef100ce501d2377922ea@209.126.116.182:209.126.116.182:26656,1f536bba1e1922d8920ab742afd8c78b447c68b2@194.163.178.191:tcp://0.0.0.0:26676,aec1624fad0adf47f9b4f7300dcb8bd4d63567f1@57.128.20.163:144.76.40.53:21756,86679da4bda37e8f26ce7964c2c1590c48fad56b@195.201.193.224:tcp://0.0.0.0:26656,e66f0506ab0f2b19e123d2ba803327e225bdb916@65.108.210.137:tcp://0.0.0.0:26656,8d861db065439e8cff79d0d128ce0a141025be46@65.109.69.154:tcp://0.0.0.0:40656,5a95e7a2d751128fd161e1429535918eaa0e459e@65.109.88.251:tcp://0.0.0.0:11086,a441f804c896d3bb3ecd0cee775b379dd1322f62@69.197.2.27:tcp://0.0.0.0:26656,22a0ca5f64187bb477be1d82166b1e9e184afe50@18.143.52.13:tcp://0.0.0.0:26656,b6a0d0d030f35ffffcfe92e72ea13933c1adbe62@116.202.174.253:tcp://0.0.0.0:21656,d1a6bdf28f8d8b8ff7278e468e0f83481be62f7e@176.9.121.109:tcp://0.0.0.0:41856,fa474fe8f7159c9699fb39acb2925702f0474502@141.95.157.139:tcp://141.95.157.139:10156,d67d09b46490e6b6376a5c2a31c3f52854769071@136.243.67.189:136.243.67.189:21756,5e87d03a29ceca5e376e55588d9b099bb5d9524f@136.38.13.212:thesilverfox.asuscomm.com:25656,95da8abac04d76e02ad175f0ed63d8fd89ab2dc6@65.109.97.249:65.109.97.249:21756,edbd221ceecf4e0234fb60d617a025c6b0e56bf0@178.250.154.15:tcp://0.0.0.0:36656,5d9146e9446df65ac30dd0a2dcb7e5887aaa6fa6@146.59.70.180:tcp://0.0.0.0:26656,65bf908c6c41cacfce9652ed69a17337b023d0d0@57.128.85.172:57.128.85.172:26656,a859027129ee2524b57c43b9ecbe3bcc4d120efb@195.3.222.183:195.3.222.183:26656,a58b4dec687b60ba05cf9a3e4cd1181b09c0661f@65.109.93.152:65.109.93.152:34656,94ea862e3716ddecc0888b047b731edcc42a752d@206.81.24.212:tcp://0.0.0.0:26656,f0c43af5395c36e41fcf7526c05d3c44e97b9499@185.165.241.20:tcp://0.0.0.0:26656,5d67a0f85788eb0e2a06e58b03d1332d995c8ccd@65.109.111.29:tcp://0.0.0.0:27656,035b3b1e232107dda53f79d7ae3541e86c53f1d8@52.87.238.111:tcp://0.0.0.0:26656,1584b3aa3969def4a9f70555b3b442d334053e94@148.113.159.22:tcp://148.113.159.22:10156,ebc272824924ea1a27ea3183dd0b9ba713494f83@95.214.52.139:95.214.52.139:26966,ad1febeb65726dd3f7c4083aac558ebda85a74ed@3.89.124.251:tcp://0.0.0.0:26656,310d60544edc798f46321411ed2dda6d83a141e9@65.108.141.109:tcp://0.0.0.0:54656,5ce29d0d9ef1230eab07444dd73745d68a832d6f@65.109.106.172:tcp://0.0.0.0:40656,7ff603bf2eb8249b9a1e695a232d99fdaf8a0f13@195.201.197.159:195.201.197.159:26156,7ddcc37b64aed1b3386aaf561c6d6a4949fe06b6@134.209.73.99:tcp://0.0.0.0:26656,a8b07b528de5bde0a7d1c09a27d8cf3983905c41@209.159.148.90:209.159.148.90:26656,f43c7c9a194ee5a97665a9aad8f887fdbb75e4ca@65.109.225.86:65.109.225.86:46656,ee5dcdba835ca45249e13955da89257d67064548@142.44.213.82:tcp://0.0.0.0:7530,4f95e3b40a652b758d551a0d3a6cc25603d9e179@38.242.150.61:38.242.150.61:27656,34d759895c5a451488db34c686e74cb954d86723@65.108.135.212:65.108.135.212:26656,b91ee5c72905bc49beed2720bb882c923c68fbc9@5.9.147.22:tcp://0.0.0.0:36656,dce07d176e5ba4cfdc7b806eb80eabab162a09d0@45.76.213.229:45.76.213.229:26656,e461719028a713ba2353e67fa9cd46e75dfd4a5f@8.218.103.26:tcp://0.0.0.0:26656,dc9c2ab4055a2ef8ddca435e9d8c120969562f98@194.247.13.139:194.247.13.139:26656,4162aee1fe7809d7647bb6c4b560b1563d9445f0@65.108.75.174:127.0.0.1:41656,7885a9e940b45b9a2183488ca3a901b043b6ed67@144.76.40.53:144.76.40.53:21756,63a90346040657406ddc48a2679e3bfbe17f717a@65.108.195.29:tcp://0.0.0.0:51656,bdd32536c902de9b240a36f0b23641233a080351@65.109.71.35:tcp://0.0.0.0:27656,e809bf8673a477324d5f0d9b6093ab12bac2800b@185.16.39.164:185.16.39.164:21756,d643251584363c611326ea414fc9a898ce4ee9a2@38.242.249.1:tcp://0.0.0.0:26656,9ee34b0829e9d85d88784aa17857fa1719760da2@142.132.202.86:tcp://0.0.0.0:30000,3e7ef25f1c9829351936884618659167400eb0f1@142.132.149.171:142.132.149.171:26656,a60a9f3400cb978b313ad5a47d59f6c518ef2a04@3.135.201.61:tcp://0.0.0.0:26656,1a0ec8407bc5df606c3951bed14ee41e176148ca@5.9.95.147:tcp://0.0.0.0:26656,07317346ab58eb4de14fe8c7705863002186d340@142.132.201.53:tcp://0.0.0.0:36656,dd6474ec049a264abd25248f0fd9178058331fe0@54.179.159.96:tcp://0.0.0.0:26656,6ed608c29c10d43c457b0fc8701d09a205d6ad73@95.216.199.9:tcp://0.0.0.0:26656,0179528068da0dfaf61005cf5aa28793ca42b129@85.25.74.163:85.25.74.163:26656,41caa4106f68977e3a5123e56f57934a2d34a1c1@95.214.53.215:95.214.53.215:26966,5c719d6c950943a6b0cbe592c9979703bd64f024@65.108.238.219:65.108.238.219:21756,b39d0c01e5bc2ccc4949ff77fe7df6ba162ea599@51.89.195.66:tcp://0.0.0.0:25656,0599779759ed60e12ed39a94cd02d303ba10d591@95.214.52.174:tcp://0.0.0.0:36656,e7899a228deb03334708aa95a960d5a9d8c33287@65.108.238.166:65.108.238.166:21756,dcd54be648739c69a700ff1e92365889a0c0771d@208.77.197.83:208.77.197.83:27656,c2215f1673d21a7462f38bf7fbd16f8567393f7c@13.251.159.166:tcp://0.0.0.0:26656,ced3a13f4f7200ce1a2392a5738c88532f794359@65.108.232.168:tcp://0.0.0.0:25656,d9bfa29e0cf9c4ce0cc9c26d98e5d97228f93b0b@65.109.88.38:tcp://0.0.0.0:11756,a8206b951ca576c96810282341e7ff3dc0406dd6@188.172.228.225:tcp://0.0.0.0:11656,57406c041d38af3bac9acdcb2b4bdc90dc7a8852@88.99.164.158:88.99.164.158:26656,9755cab2585a2794453a5b396ef13b893393366f@65.108.212.224:tcp://0.0.0.0:46681"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$AURA_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$AURA_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $AURA_GENESIS > $HOME/$AURA_FOLDER/config/genesis.json
curl -Ls $AURA_ADDRBOOK > $HOME/$AURA_FOLDER/config/addrbook.json

#Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${AURA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${AURA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${AURA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${AURA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${AURA_PORT}660\"%" $HOME/$AURA_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${AURA_PORT}317\"%; s%^address = \":8080\"%address = \":${AURA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${AURA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${AURA_PORT}091\"%" $HOME/$AURA_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$AURA_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$AURA_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$AURA_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$AURA_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$AURA_DENOM\"/" $HOME/$AURA_FOLDER/config/app.toml

# enable snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$AURA_FOLDER/config/app.toml

$AURA tendermint unsafe-reset-all --home $HOME/$AURA_FOLDER --keep-addr-book

# Create Service
sudo tee /etc/systemd/system/$AURA.service > /dev/null << EOF
[Unit]
Description=$AURA
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $AURA) start --home $HOME/$AURA_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $AURA
sudo systemctl start $AURA

echo -e "\033[38;2;4;204;255mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \033[38;2;4;204;255mjournalctl -fu $AURA -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \033[38;2;4;204;255mcurl -s localhost:${AURA_PORT}657/status | jq .result.sync_info\e[0m"
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
