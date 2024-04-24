#!/bin/bash
export LANG=C.UTF-8
export DEBIAN_FRONTEND=noninteractive
[ -z $VER ] && exit 1

apt-get -y update
apt-get -y upgrade
apt-get -y install libbluray-dev git build-essential dpkg-dev devscripts

cd /work && rm -rf *
git clone https://github.com/schnusch/bdinfo
cd bdinfo
git reset --hard "$VER"
cp -rv /contrib/debian .
dpkg-buildpackage --no-sign
mv /work/*deb /output
