#!/bin/bash 
set -ex
export DEBIAN_FRONTEND=noninteractive
mkdir -p /work/$RELEASE

if grep -qi ubuntu /etc/os-release ; then 
    echo "deb-src http://archive.ubuntu.com/ubuntu $RELEASE main" | tee -a /etc/apt/sources.list
else
    echo "deb-src http://deb.debian.org/debian/ $RELEASE main" | tee -a /etc/apt/sources.list
fi

cd /work/$RELEASE
rm -rf *

apt-get -y update
apt-get -y upgrade
apt-get -y install build-essential cmake debhelper qtbase5-dev libqt5websockets5-dev qtwebengine5-dev wget pkg-config qttools5-dev qt5keychain-dev

wget --content-d https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v$VER/globalprotect-openconnect-$VER.tar.gz
tar xvf globalprotect-openconnect-$VER.tar.gz
cd globalprotect-openconnect-$VER

if grep -qi ubuntu /etc/os-release ; then
    echo "override_dh_builddeb:" >> debian/rules
    echo "	dh_builddeb -- -Zgzip" >> debian/rules
fi

sed -i 's/-1//' debian/changelog
dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
