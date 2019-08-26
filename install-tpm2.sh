set -e

id -u tss &>/dev/null || useradd -r -s /bin/false tss

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
cd /tmp


# install TSS itself
rm -rf tpm2-tss
git clone https://github.com/tpm2-software/tpm2-tss.git
cd tpm2-tss
rm -rf /usr/local/share/man/man3/Tss2_TctiLdr_Initialize_Ex.3
./bootstrap
./configure
make check
sudo make install




# Install abrmd itself
rm -rf tpm2-abrmd
git clone https://github.com/tpm2-software/tpm2-abrmd.git
cd tpm2-abrmd
git checkout tags/2.2.0
./bootstrap
./configure --with-dbuspolicydir=/etc/dbus-1/system.d
dbus-launch make check
sudo make install


# Install tools itself
git clone https://github.com/tpm2-software/tpm2-tools.git
cd tpm2-tools
#git checkout tags/3.2.0
./bootstrap
./configure
make check
sudo make install



# install TSS engine
rm -rf tpm2-tss-engine
git clone https://github.com/tpm2-software/tpm2-tss-engine.git
cd tpm2-tss-engine
./bootstrap
./configure
make check
sudo make install



sudo ldconfig
chown tss:tss /dev/tpm*
sudo systemctl enable tpm2-abrmd.service
sudo systemctl start tpm2-abrmd.service


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

cat <<EOF >~/.tpm2/config
# Type can be device/socket/tabrmd
type abrmd:bus_name=com.intel.tss2.Tabrmd
# Hostname to connect when using socket
# hostname localhost
# Port number of TPM socket to connect to
# port 2321
# Device to use as TPM
device /dev/tpmrm0
# Sign using encrypt in case TPM doesn't support hash format
# For example SSH use SHA512 which isn't supported by all TPM's
# Enabling this option requires key's to be encryption keys instead of signing only keys
sign-using-encrypt true
# Set login_required in case keys are protected by a password
# Notice currently only a single password for all keys is supported
# Depending on the TPM settings, providing wrong passwords can lead to a lockout
login-required false
# Enable logging
# None: 0
# Error: 1
# Warning: 2
# Info: 3
# Verbose: 4
# Debug: 5
log-level 2
# Set log file location or use stdout/stderr
log stderr
#############################
EOF

