#!/bin/sh

wget http://ipfslhy1.tpddns.cn:81/go-ipfs_v0.7.0_linux-amd64.tar.gz
tar xvfz go-ipfs_v0.7.0_linux-amd64.tar.gz
mv go-ipfs/ipfs /usr/local/bin/ipfs
#初始化ipfs
ipfs init
wget https://sdxtlhy.github.io/ipfs/config
sed -i "s/192.168.0.200/$1/g" config
mv .ipfs/config .ipfs/config.bak
mv config .ipfs/config

wget https://sdxtlhy.github.io/ipfs/centos7setup.tar
#解壓
tar -xf centos7setup.tar
chmod +x checkhash.sh
chmod +x startipfs.sh
date >>ipns.id
#startipfs.sh中包含了firewall-cmd --add-port=8080/tcp及5001/tcp，防火墻開放8080及5001 tcp端口
./startipfs.sh
./checkhash.sh

cp /etc/crontab /etc/crontab.bak
sed -i "s/PATH=/PATH=\/usr\/local\/bin:/g" /etc/crontab
echo "$(date +%M) * * * * root /root/checkhash.sh" >>/etc/crontab

cp /etc/rc.d/rc.local /etc/rc.d/rc.local.bak
echo "su -c /root/startipfs.sh" >>/etc/rc.local
chmod +x /etc/rc.d/rc.local

#reboot



