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
apt-get -y install debhelper devscripts dh-python intltool pyflakes3 python3-all python3-apt python3-distutils-extra dpkg-dev wget

[ -z $VER ] && VER=18.04.6
wget http://archive.ubuntu.com/ubuntu/pool/main/c/command-not-found/command-not-found_$VER.tar.gz
tar xvf command-not-found_$VER.tar.gz
cd command-not-found-$VER

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "Debian port of Ubuntu's c-n-f"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
