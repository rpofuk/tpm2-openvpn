#!/bin/bash 

set -xe

sudo id -u tss 2>/dev/null || sudo useradd -r -s /bin/false tss

sudo apt-get update
sudo apt-get install -y build-essential
sudo apt-get install -y git
# install package manager deps for tools
sudo apt-get install -y pandoc autoconf-archive
sudo apt-get install -y libcurl4-openssl-dev libssl-dev doxygen
sudo apt-get install -y autoconf autoconf-archive automake libtool pkg-config gcc libssl-dev libcurl4-gnutls-dev

# install package manager deps for abrmd
# Note: the dbus-x11 dependency is for dbus-launch not for abrmd itself.
sudo apt-get -y install libdbus-1-dev libglib2.0-dev dbus-x11

rm -fr $HOME/.tpm2
mkdir -p $HOME/.tpm2

rm -fr $HOME/install
mkdir -p $HOME/install



# install TSS itself
cd $HOME/install
rm -rf tpm2-tss
git clone https://github.com/tpm2-software/tpm2-tss.git
cd tpm2-tss
git checkout tags/2.3.0
sudo rm -rf /usr/local/share/man/man3/Tss2_TctiLdr_Initialize_Ex.3
./bootstrap || echo "Attempt 1"
./bootstrap
./configure --with-udevrulesdir=/etc/udev/rules.d
make check
sudo make install




# Install abrmd itself
cd $HOME/install
rm -rf tpm2-abrmd
git clone https://github.com/tpm2-software/tpm2-abrmd.git
cd tpm2-abrmd
git checkout tags/2.2.0
./bootstrap || echo "Attempt 1"
./bootstrap
./configure --with-dbuspolicydir=/etc/dbus-1/system.d
dbus-launch make check
sudo make install


# Install tools itself
cd $HOME/install
git clone https://github.com/tpm2-software/tpm2-tools.git
cd tpm2-tools
git checkout tags/4.0-rc1
./bootstrap || echo "Attempt 1"
./bootstrap
./configure
make check
sudo make install



# install TSS engine
cd $HOME/install
rm -rf tpm2-tss-engine
git clone https://github.com/tpm2-software/tpm2-tss-engine.git
cd tpm2-tss-engine
git checkout tags/v1.0.1
./bootstrap
./configure
make check
sudo make install

sudo cat > /tmp/tpm2-abrmd.service <<'EOL'
[Unit]
Description=TPM2 Access Broker and Resource Management Daemon

[Service]
Type=dbus
Restart=always
RestartSec=5
BusName=com.intel.tss2.Tabrmd
StandardOutput=syslog
ExecStart=/usr/local/sbin/tpm2-abrmd --tcti "device:/dev/tpmrm0"
User=tss

[Install]
WantedBy=multi-user.target

EOL

sudo mv /tmp/tpm2-abrmd.service  /etc/systemd/system/tpm2-abrmd.service

sudo ldconfig
sudo systemctl daemon-reload
sudo systemctl enable tpm2-abrmd.service


sudo apt-get install -y liblz4-dev
sudo apt-get install -y liblzo2-dev
sudo apt-get install -y libpam-dev
sudo apt-get install net-tools

git clone https://github.com/rpofuk/openvpn.git
cd openvpn
git checkout feature/tpm2-tss
autoreconf -i -v -f
./configure
make 
sudo rm -rf /usr/sbin/openvpn
sudo ln -s $PWD/src/openvpn/openvpn /usr/sbin/openvpn

echo "TPM2TOOLS_TCTI=tabrmd:bus_name=com.intel.tss2.Tabrmd" | sudo tee -a /etc/environment 

echo "INSTALL CHROME"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb


echo "INSTALL NODE"
sudo apt-get install -y curl

curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -

VERSION=node_12.x
DISTRO="disco"
echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list
echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list

sudo apt-get update
sudo apt-get install -y nodejs


echo "Done"

echo 'Reboot? (y/n)' && read x && [[ "$x" == "y" ]] && /sbin/reboot;

