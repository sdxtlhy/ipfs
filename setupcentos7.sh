#!/bin/sh

yum -y install psmisc

echo install $HOSTTYPE ...
if  [ $HOSTTYPE = "x86_64" ]; then
    rm go-ipfs_v0.8.0_linux-amd64.tar.gz
    #wget https://github.com/ipfs/go-ipfs/releases/download/v0.8.0/go-ipfs_v0.8.0_linux-amd64.tar.gz
    #wget http://ipfslhy1.tpddns.cn:81/go-ipfs_v0.8.0_linux-amd64.tar.gz
    wget http://106.13.206.237/go-ipfs_v0.8.0_linux-amd64.tar.gz
    tar xvfz go-ipfs_v0.8.0_linux-amd64.tar.gz
else
    rm go-ipfs_v0.8.0_linux-386.tar.gz
    #wget https://github.com/ipfs/go-ipfs/releases/download/v0.8.0/go-ipfs_v0.8.0_linux-386.tar.gz
    #wget http://ipfslhy1.tpddns.cn:81/go-ipfs_v0.8.0_linux-386.tar.gz
    wget http://106.13.206.237/go-ipfs_v0.8.0_linux-386.tar.gz
    tar xvfz go-ipfs_v0.8.0_linux-386.tar.gz
fi

rm .ipfs -r -f
mv go-ipfs/ipfs /usr/local/bin/ipfs
#初始化ipfs
ipfs init
rm config
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

rm centos7setup.tar
wget https://sdxtlhy.github.io/ipfs/centos7setup.tar
#解壓
tar -xf centos7setup.tar
chmod +x checkhash.sh
chmod +x startipfs.sh
date >ipns.id
#startipfs.sh中包含了firewall-cmd --add-port=8080/tcp及5001/tcp，防火墻開放8080及5001 tcp端口
./startipfs.sh
echo "Geting Duosuccess IPFS Latest Hash Data,please waiting..."
rm checkhash.runing
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

