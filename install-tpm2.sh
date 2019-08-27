#!/bin/bash 

set -xe

sudo id -u tss 2>/dev/null || sudo useradd -r -s /bin/false tss

sudo apt-get update
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
rm -rf tpm2-tss
git clone https://github.com/tpm2-software/tpm2-tss.git
cd tpm2-tss
rm -rf /usr/local/share/man/man3/Tss2_TctiLdr_Initialize_Ex.3
./bootstrap
./configure --with-udevrulesdir=/etc/udev/rules.d
make check
sudo make install




# Install abrmd itself
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
git clone https://github.com/tpm2-software/tpm2-tools.git
cd tpm2-tools
#git checkout tags/3.2.0
./bootstrap || echo "Attempt 1"
./bootstrap
./configure
make check
sudo make install



# install TSS engine
git clone https://github.com/tpm2-software/tpm2-tools.git
cd tpm2-tools
#git checkout tags/3.2.0
./bootstrap || echo "Attempt 1"
./bootstrap
./configure
make check
sudo make install



sudo ldconfig
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

echo "TPM2TOOLS_TCTI=device:/dev/tpmrm0" | sudo tee -a /etc/environmen

echo "Done"


