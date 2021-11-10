#!/bin/bash

IPFSVER="VER$1"
if  [ $IPFSVER = "VER" ]; then 
   echo "please enter go-ipfs_version then retry..."
   echo "sample:"
   echo "./setupubuntu16.sh 0.10.0"  
   exit 1
fi

echo install $HOSTTYPE ...

export GOIPFS_VERSION=$1

killall ipfs
sleep 10

if  [ $HOSTTYPE = 'x86_64' ]; then
    rm go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz -f
    #wget https://github.com/ipfs/go-ipfs/releases/download/v${GOIPFS_VERSION}/go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz
    wget http://8.142.134.6/go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz
    tar xvfz go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz
else
    rm go-ipfs_v${GOIPFS_VERSION}_linux-386.tar.gz -f
    #wget https://github.com/ipfs/go-ipfs/releases/download/v${GOIPFS_VERSION}/go-ipfs_v${GOIPFS_VERSION}_linux-386.tar.gz    
    wget http://8.142.134.6/go-ipfs_v${GOIPFS_VERSION}_linux-386.tar.gz
    tar xvfz go-ipfs_v${GOIPFS_VERSION}_linux-386.tar.gz
fi

rm .ipfs -r -f
rm /usr/local/bin/ipfs -f

mv go-ipfs/ipfs /usr/local/bin/ipfs
#初始化ipfs
ipfs init
rm config -f
wget https://sdxtlhy.github.io/ipfs/config
MYIP=`hostname -I`
MYIPLEN=`expr ${#MYIP} - 1`
MYIP=`expr substr $MYIP 1 $MYIPLEN`
sed -i "s/192.168.0.200/$MYIP/g" config

BAKNUM=`date +"%Y-%m-%d %H:%M:%S"`
BAKNUMSTR=`date -d "$BAKNUM" +%s`
CONFIGBAKNAME=".ipfs/config.$BAKNUMSTR"
mv .ipfs/config $CONFIGBAKNAME
mv config .ipfs/config
rm ubuntusetup.tar -f
wget https://sdxtlhy.github.io/ipfs/ubuntusetup.tar
#解壓
tar -xf ubuntusetup.tar
chmod +x checkhash.sh
chmod +x startipfs.sh
date >ipns.id
echo "Geting Duosuccess IPFS Latest Hash Data,please waiting..."
rm checkhash.runing -f
./checkhash.sh

CRONTABBAKNAME="/etc/crontab.$BAKNUMSTR"
cp /etc/crontab $CRONTABBAKNAME
sed -i '/* * * * root \/root\/checkhash.sh/d' /etc/crontab
echo "$(date +%M) * * * * root /root/checkhash.sh" >>/etc/crontab

RCLOCALBAKNAME="/etc/rc.local.$BAKNUMSTR"
cp /etc/rc.local $RCLOCALBAKNAME
grep "su -c /root/startipfs.sh" /etc/rc.local
if [ $? != 0 ];then
  sed -i '/exit/d' /etc/rc.local
  echo "su -c /root/startipfs.sh" >>/etc/rc.local
  echo "exit 0" >>/etc/rc.local
fi
#
sed -i '/HandleLidSwitch=/d' /etc/systemd/logind.conf
echo "HandleLidSwitch=ignore" >>/etc/systemd/logind.conf

echo "setup Duosuccess IPFS Successfull！"
#reboot

