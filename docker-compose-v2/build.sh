#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
mkdir -p /work/$RELEASE

[ -z $VER ]    && VER=2.20.2
[ -z $MOD ]    && MOD=+ds1
[ -z $BRANCH ] && BRANCH=-0ubuntu1

cd /work/$RELEASE
rm -rf *

apt-get -y update
apt-get -y upgrade
apt-get -y install dpkg-dev devscripts git dh-golang golang-go

git clone --recurse-submodules -b ubuntu/$VER$MOD$BRANCH https://github.com/canonical/docker-compose-v2
cd $(find . -maxdepth 1 -mindepth 1 -type d)

curl -L https://github.com/canonical/docker-compose-v2/archive/refs/tags/upstream/$VER$MOD.tar.gz > ../docker-compose-v2_$VER$MOD.orig.tar.gz

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "Debian port of Ubuntu's docker-compose-v2"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
