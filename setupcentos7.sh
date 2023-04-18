#!/bin/sh

IPFSVER="VER$1"
if  [ $IPFSVER = "VER" ]; then 
   echo "please enter go-ipfs_version then retry..."
   echo "sample:"
   echo "./setupcentos7.sh 0.19.1"  
   exit 1
fi

yum -y install psmisc

echo install $HOSTTYPE ...

export GOIPFS_VERSION=$1

killall ipfs
sleep 10

if  [ $HOSTTYPE = "x86_64" ]; then
    rm kubo_v${GOIPFS_VERSION}_linux-amd64.tar.gz -f
    #wget https://github.com/ipfs/kubo/releases/download/v${GOIPFS_VERSION}/kubo_v${GOIPFS_VERSION}_linux-amd64.tar.gz
    wget http://8.142.134.6/kubo_v${GOIPFS_VERSION}_linux-amd64.tar.gz
    tar xvfz kubo_v${GOIPFS_VERSION}_linux-amd64.tar.gz
else
    rm kubo_v${GOIPFS_VERSION}_linux-386.tar.gz -f
    #wget https://github.com/ipfs/kubo/releases/download/v${GOIPFS_VERSION}/kubo_v${GOIPFS_VERSION}_linux-386.tar.gz
    wget http://8.142.134.6/kubo_v${GOIPFS_VERSION}_linux-386.tar.gz
    tar xvfz kubo_v${GOIPFS_VERSION}_linux-386.tar.gz
fi

rm .ipfs -r -f
rm /usr/local/bin/ipfs -f

mv kubo/ipfs /usr/local/bin/ipfs
#初始化ipfs
ipfs init
rm config -f
wget https://sdxtlhy.github.io/ipfs/config
MYIP=`hostname -I`
MYIPLEN=`expr ${#MYIP} - 1`
MYIP=`expr substr $MYIP 1 $MYIPLEN`
sed -i "s/192.168.0.200/$MYIP/g" config
sed -i "s/QmSeJ41iXwebzm3KPTixBc3zoetBD61df76BRjE4RuY4YB/12D3KooWACwFV6WAzonbCLYo3r5JxivL5jbPNx5JpEwaepHykcqR/g" config

BAKNUM=`date +"%Y-%m-%d %H:%M:%S"`
BAKNUMSTR=`date -d "$BAKNUM" +%s`
CONFIGBAKNAME=".ipfs/config.$BAKNUMSTR"
mv .ipfs/config $CONFIGBAKNAME
mv config .ipfs/config

rm centos7setup.tar -f
wget https://sdxtlhy.github.io/ipfs/centos7setup.tar
#解壓
tar -xf centos7setup.tar
sed -i "s/QmSeJ41iXwebzm3KPTixBc3zoetBD61df76BRjE4RuY4YB/12D3KooWACwFV6WAzonbCLYo3r5JxivL5jbPNx5JpEwaepHykcqR/g" checkhash.sh

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

sed -i '/HandleLidSwitch=/d' /etc/systemd/logind.conf
echo "HandleLidSwitch=ignore" >>/etc/systemd/logind.conf

echo "setup Duosuccess IPFS Successfull！"
#reboot

