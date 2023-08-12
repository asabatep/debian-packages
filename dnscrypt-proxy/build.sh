#!/bin/bash 
set -ex
export DEBIAN_FRONTEND=noninteractive
mkdir -p /work/$RELEASE

cd /work/$RELEASE
rm -rf *


cat > /etc/apt/preferences << EOF
Package: *
Pin: release a=stable
Pin-Priority: 501

Package: *
Pin: release a=testing
Pin-Priority: 499
EOF

sed 's/deb$/deb-src/' /etc/apt/sources.list.d/debian.sources > /etc/apt/sources.list.d/bookworm.sources
sed 's/deb$/deb-src/' /etc/apt/sources.list.d/debian.sources > /etc/apt/sources.list.d/debsrc.sources
cat /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/bookworm.sources | sed 's/bookworm/trixie/g' > /etc/apt/sources.list.d/trixie.sources

apt-get -y update
apt-get -y upgrade
apt-get -y install devscripts dpkg-dev
apt-get -y build-dep dnscrypt-proxy

apt-get source -t trixie dnscrypt-proxy
cd $(find . -maxdepth 1 -mindepth 1 -type d)

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "backport for bookworm"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
