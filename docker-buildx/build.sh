#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
mkdir -p /work/$RELEASE

[ -z $VER ]    && VER=0.11.2
[ -z $MOD ]    && MOD=-
[ -z $BRANCH ] && BRANCH=0ubuntu1

cd /work/$RELEASE
rm -rf *

apt-get -y update
apt-get -y upgrade
apt-get -y install dpkg-dev devscripts git dh-golang golang-go

git clone -b ubuntu/$VER$MOD$BRANCH https://github.com/canonical/docker-buildx
cd $(find . -maxdepth 1 -mindepth 1 -type d)

curl -L https://github.com/canonical/docker-buildx/archive/refs/tags/upstream/$VER.tar.gz > ../docker-buildx_$VER.orig.tar.gz

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "Debian port of Ubuntu's docker-buildx"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
