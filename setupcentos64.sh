#!/bin/sh

IPFSVER="VER$1"
if  [ $IPFSVER = "VER" ]; then 
   echo "please enter go-ipfs_version ip then retry..."
   echo "sample:"
   echo "./setupcentos64.sh 0.8.0 xxx.xxx.xxx.xxx"  
   exit 1
fi

IPSTR="ip$2"
if  [ $IPSTR = "ip" ]; then 
   echo "please enter go-ipfs_version ip then retry..."
   echo "sample:"
   echo "./setupcentos64.sh 0.8.0 xxx.xxx.xxx.xxx"  
   exit 1
fi

yum -y install psmisc

GOIPFS_VERSION = $1

killall ipfs
sleep 10
rm go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz -f
rm .ipfs -r -f
rm /usr/local/bin/ipfs -f

#wget https://github.com/ipfs/go-ipfs/releases/download/v${GOIPFS_VERSION}/go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz
wget http://106.13.206.237/go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz

tar xvfz go-ipfs_v${GOIPFS_VERSION}_linux-amd64.tar.gz
mv go-ipfs/ipfs /usr/local/bin/ipfs

#初始化ipfs
ipfs init
rm config -f
wget https://sdxtlhy.github.io/ipfs/config
sed -i "s/192.168.0.200/$2/g" config

BAKNUM=`date +"%Y-%m-%d %H:%M:%S"`
BAKNUMSTR=`date -d "$BAKNUM" +%s`
CONFIGBAKNAME=".ipfs/config.$BAKNUMSTR"
mv .ipfs/config $CONFIGBAKNAME
mv config .ipfs/config

rm centos7setup.tar -f
wget https://sdxtlhy.github.io/ipfs/centos7setup.tar
#解壓
tar -xf centos7setup.tar
chmod +x checkhash.sh
chmod +x startipfs.sh
date >ipns.id
#startipfs.sh中包含了firewall-cmd --add-port=8080/tcp及5001/tcp，防火墻開放8080及5001 tcp端口
./startipfs.sh
echo "Geting Duosuccess IPFS Latest Hash Data,please waiting..."
rm checkhash.runing -f
./checkhash.sh

CRONTABBAKNAME="/etc/crontab.$BAKNUMSTR"
cp /etc/crontab $CRONTABBAKNAME
sed -i "s/PATH=\/sbin:/PATH=\/usr\/local\/bin:\/sbin:/g" /etc/crontab
sed -i '/* * * * root \/root\/checkhash.sh/d' /etc/crontab
echo "$(date +%M) * * * * root /root/checkhash.sh" >>/etc/crontab

RCLOCALBAKNAME="/etc/rc.d/rc.local.$BAKNUMSTR"
cp /etc/rc.d/rc.local $RCLOCALBAKNAME
grep "su -c /root/startipfs.sh" /etc/rc.local
if [ $? != 0 ];then
  echo "su -c /root/startipfs.sh" >>/etc/rc.d/rc.local
fi
chmod +x /etc/rc.d/rc.local
echo "setup Duosuccess IPFS Successfull！"
#reboot

