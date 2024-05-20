#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
export THISPKG=docker-buildx
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
    apt-get -t trixie -y install dh-golang golang-go devscripts
    apt-get -y install dpkg-dev git xmlstarlet
else
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install dh-golang golang-go devscripts dpkg-dev git xmlstarlet
fi

cd /work/$RELEASE
rm -rf *

FEED=/dev/shm/releases.atom
curl -o $FEED https://github.com/canonical/$THISPKG/releases.atom

DVER=$(xmlstarlet sel -t -m "/*[local-name()='feed']/*[local-name()='entry']" -v "*[local-name()='id']" -n $FEED | awk -F/ '{print $NF}' | sort -n | grep ubuntu | tail -n1)
UVER=$(xmlstarlet sel -t -m "/*[local-name()='feed']/*[local-name()='entry']" -v "*[local-name()='id']" -n $FEED | awk -F/ '{print $NF}' | sort -n | grep -v ubuntu | tail -n1)

git clone --recurse-submodules -b ubuntu/$DVER https://github.com/canonical/$THISPKG
cd $(find . -maxdepth 1 -mindepth 1 -type d)
patch -p1 < /src/revert-build-go-1.21.patch

curl -L https://github.com/canonical/$THISPKG/archive/refs/tags/upstream/$UVER.tar.gz -o ../${THISPKG}_${UVER}.orig.tar.gz

NAME="repo.lol" EMAIL="pkgs@repo.lol" dch --nmu "Debian port of Ubuntu's $THISPKG"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
