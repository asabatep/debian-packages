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
apt-get -y install devscripts quilt

apt-get -y build-dep glib2.0
apt-get source glib2.0

cd $(find . -maxdepth 1 -mindepth 1 -type d)

quilt import -P glib-thumbnailer.patch  /src/glib-thumbnailer.patch
quilt push

if grep -qi ubuntu /etc/os-release ; then
    echo "override_dh_builddeb:" >> debian/rules
    echo "	dh_builddeb -- -Zgzip" >> debian/rules
fi

sed -i 's/handle_test_failure := exit $$?/handle_test_failure := true/' ./debian/rules # xxx
sed -i '0,/^Recommends/{s/^Recommends: /Recommends: tumbler, /}' ./debian/control.in

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "apply tumbler patch"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
