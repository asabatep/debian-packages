#!/bin/bash
export LANG=C.UTF-8

[ -z $VER ] && exit 1

apt-get -y update
apt-get -y upgrade
apt-get -y install wget ghc haskell-stack dpkg-dev devscripts

cd /work && rm -rf *
wget -O hadolint_$VER.orig.tar.gz https://github.com/hadolint/hadolint/archive/refs/tags/v$VER.tar.gz
tar xvf hadolint_$VER.orig.tar.gz
cd hadolint-$VER
cp -rv /contrib/debian .
debuild -us -uc
mv /work/*deb /output
