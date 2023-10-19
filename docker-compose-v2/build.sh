#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
mkdir -p /work/$RELEASE

if grep bookworm /etc/os-release ; then
    cat > /etc/apt/preferences << EOF
Package: *
Pin: release a=stable
Pin-Priority: 900

Package: *
Pin: release a=testing
Pin-Priority: -1
EOF
    sed 's/bookworm/trixie/g' /etc/apt/sources.list.d/debian.sources > /etc/apt/sources.list.d/trixie.sources
    apt-get -y update
    apt-get -y upgrade
    apt-get -t trixie -y install dh-golang golang-go
else
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install dh-golang golang-go
fi

[ -z $VER ]    && VER=2.20.2
[ -z $MOD ]    && MOD=+ds1
[ -z $BRANCH ] && BRANCH=-0ubuntu1

cd /work/$RELEASE
rm -rf *

apt-get -y install dpkg-dev devscripts git 

git clone --recurse-submodules -b ubuntu/$VER$MOD$BRANCH https://github.com/canonical/docker-compose-v2
cd $(find . -maxdepth 1 -mindepth 1 -type d)

curl -L https://github.com/canonical/docker-compose-v2/archive/refs/tags/upstream/$VER$MOD.tar.gz > ../docker-compose-v2_$VER$MOD.orig.tar.gz

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "Debian port of Ubuntu's docker-compose-v2"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
