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

apt-get -y build-dep gtk+3.0
apt-get source gtk+3.0
cd $(find . -maxdepth 1 -mindepth 1 -type d)

quilt import -P gtk3-filechooser-icon-view.patch  /src/gtk3-filechooser-icon-view.patch
quilt push

if grep -qi ubuntu /etc/os-release ; then
    echo "override_dh_builddeb:" >> debian/rules
    echo "	dh_builddeb -- -Zgzip" >> debian/rules
fi

sed -i 's/xvfb-run/true/g' ./debian/rules # xxx
sed -i 's/debian\/run-tests.sh/true/g' ./debian/rules

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "apply filechooser patch"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
