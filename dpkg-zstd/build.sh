#!/bin/bash 
set -eux
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
apt-get -y install devscripts quilt libzstd-dev zstd

apt-get -y build-dep dpkg
apt-get source dpkg

cd $(find . -maxdepth 1 -mindepth 1 -type d)

if grep -qi bullseye /etc/os-release ; then
    quilt import -P zstd-support-bullseye.patch /src/zstd-support-bullseye.patch
else
    quilt import -P zstd-support.patch /src/zstd-support.patch
fi
quilt push -a

if grep -qi ubuntu /etc/os-release ; then
    echo "override_dh_builddeb:" >> debian/rules
    echo "	dh_builddeb -- -Zgzip" >> debian/rules
fi

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "add zstd support"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
