#!/bin/bash
################ SERVER CONFIGURATION ##########################
user=$1

sudo apt-get update
sudo apt-get install openvpn easy-rsa -y
make-cadir /home/$user/openvpn-ca

cd /home/$user/openvpn-ca
rm vars
wget -c https://raw.githubusercontent.com/ahmddp/Misc/master/vars
source vars

./clean-all
./pkitool --initca
./pkitool client1
./pkitool --server vpnserver
./build-dh
openvpn --genkey --secret keys/ta.key

cd /home/$user/openvpn-ca/keys/
sudo cp ca.crt  vpnserver.crt vpnserver.key ta.key dh2048.pem /etc/openvpn

cd /etc/openvpn
sudo wget -c https://raw.githubusercontent.com/ahmddp/Misc/master/vpnserver.conf

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

sudo apt install python-pip -y
sudo -H pip install backports.pbkdf2
sudo -H pip install adal
sudo -H pip install PyYAML

sudo wget -c https://raw.githubusercontent.com/ahmddp/openvpn-azure-ad-auth/master/openvpn-azure-ad-auth.py
sudo chmod +x openvpn-azure-ad-auth.py

sudo systemctl start openvpn@vpnserver
