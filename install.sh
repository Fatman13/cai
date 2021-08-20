#!/bin/bash
echo -e "\033[32m 1.[install venus-wallet] 安装venus-wallet \033[0m"
echo -e "\033[32m 2.[There are already miners] 已经矿工，启动venus-sealer \033[0m"
echo -e "\033[32m 3.[Newly generated miner number] 新矿工，启动venus-sealer \033[0m"
echo -e "\033[32m 4.[exit] 退出 \033[0m"
echo -e "\033[31m [WARN: Please ensure that the /var/tmp/filecoin-proof-parameters of the venus-sealer and venus-worker hosts have all the supporting parameter files, about 102G] \033[0m"

read -p "pls input the num you want: " num

case $num in 
   1)
   if [ -f "$HOME/.venus_wallet/config.toml" ];
   then
       echo "The Venus wallet component has been installed. If you need to reinstall, please remove the $HOME/.venus_wallet directory!"
   else
       read -p "pls enter your cluster name: " name
       read -p "pls enter your cluster wallet token information: " wallet_token
       echo "Start installation"
       mv venus-wallet venus-wallet.bak.`date +%F_%H_%M_%S` > /dev/zero   2>&1 > /dev/zero 
       curl -s -o venus-wallet https://ipfser-pro.oss-cn-zhangjiakou.aliyuncs.com/venus/venus-wallet 2>&1 > /dev/zero
       chmod +x venus-wallet
       echo "Ready to start"
       nohup ./venus-wallet run &
       sleep 3;
       ps -ef | grep venus-wallet | awk '{print $2}' | xargs kill -9 > /dev/zero  2>&1 > /dev/zero 
       sed -i -e '/APIRegisterHub/,$d' $HOME/.venus_wallet/config.toml
       cat >> $HOME/.venus_wallet/config.toml << EOF
[APIRegisterHub]
RegisterAPI = ["/dns/gateway.filincubator.com/tcp/83/wss"]
Token = "$wallet_token"
SupportAccounts = ["$name"]
EOF
       sleep 2;
       nohup ./venus-wallet run 2>&1 > wallet.log &
       echo "venus-wallet startup completed!"
   fi
   exit
;;
   2)
   if [ -f "$HOME/.venussealer/config.toml" ];
   then
       echo "The Venus wallet component has been installed. If you need to reinstall, please remove the $HOME/.venussealer directory!"
   else
       read -p "pls enter your cluster name: " name
       read -p "pls enter your cluster sealer token information: " sealer_token
       read -p "pls owner address: " owner_addres
       read -p "pls worker address: " worker_addres
       read -p "pls sector size(32 or 64): " sector_size
       mv venus-sealer venus-sealer.bak.`date +%F_%H_%M_%S` > /dev/zero   2>&1 > /dev/zero 
#      curl -s -o venus-sealer https://ipfser-pro.oss-cn-zhangjiakou.aliyuncs.com/venus/venus-sealer 2>&1 > /dev/zero
       curl -o venus-sealer https://ipfser-pro.oss-cn-zhangjiakou.aliyuncs.com/venus/venus-sealer
       chmod +x venus-sealer
       ./venus-sealer init \
--owner=$owner_addres \
--worker=$worker_addres \
--from=$worker_addres \
--sector-size {$sector_size}GiB --nosync \
--auth-token $sealer_token \
--node-url /dns/node.filincubator.com/tcp/81/wss \
--gateway-url /dns/gateway.filincubator.com/tcp/83/wss \
--messager-url /dns/messager.filincubator.com/tcp/443/https
                ./venus-sealer run > sealer.log 2>&1 
                echo "venus-sealer startup completed!"
   fi
   exit
;;
   3)
   if [ -f "$HOME/.venus_wallet/config.toml" ];
   then
       echo "The Venus wallet component has been installed. If you need to reinstall, please remove the $HOME/.venussealer directory!"
   else 
       read -p "pls enter your cluster name: " name
       read -p "pls enter your cluster sealer token information: " sealer_token
       read -p "pls miner_id num: " miner_id
       read -p "pls owner address: " owner_addres
       read -p "pls worker address: " worker_addres
       read -p "pls sector size(32 or 64): " sector_size
       mv venus-sealer venus-sealer.bak.`date +%F_%H_%M_%S` > /dev/zero   2>&1 > /dev/zero 
#       curl -s -o venus-sealer https://ipfser-pro.oss-cn-zhangjiakou.aliyuncs.com/venus/venus-sealer 2>&1 > /dev/zero
       curl -o venus-sealer https://ipfser-pro.oss-cn-zhangjiakou.aliyuncs.com/venus/venus-sealer
       chmod +x venus-sealer
       ./venus-sealer init --actor $miner_id \
--owner=$owner_addres \
--worker=$worker_addres \
--from=$worker_addres \
--sector-size {$sector_size}GiB --nosync \
--auth-token $sealer_token \
--node-url /dns/node.filincubator.com/tcp/81/wss \
--gateway-url /dns/gateway.filincubator.com/tcp/83/wss \
--messager-url /dns/messager.filincubator.com/tcp/443/https
                ./venus-sealer run > sealer.log 2>&1 
                echo "venus-sealer startup completed!"
   fi
;;
   4)
   exit
;;
   *)
   echo "Input error"
   exit
;;
esac
