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
apt-get -y install devscripts quilt faketime

apt-get -y build-dep glib2.0
apt-get source glib2.0

cd $(find . -maxdepth 1 -mindepth 1 -type d)

quilt pop -a
sed -i '/glocalfileinfo-Add-support-for-xx-large-and-x-large-thumb.patch/d' debian/patches/series
sed -i '/gio-tests-Add-file-thumbnail-tests.patch/d' debian/patches/series

if grep -Eqi '(bullseye|jammy)' /etc/os-release ; then
    quilt import -P glib-thumbnailer.patch /src/glib-thumbnailer-legacy.patch
elif grep -Eqi '(lunar|mantic|noble)' /etc/os-release ; then
    quilt import -P glib-thumbnailer.patch /src/glib-thumbnailer-lunar.patch
elif grep -Eqi '(trixie|oracular|plucky)' /etc/os-release ; then
    quilt import -P glib-thumbnailer.patch /src/glib-thumbnailer-trixie.patch
else
    quilt import -P glib-thumbnailer.patch /src/glib-thumbnailer.patch
fi

if ! grep ThumbMD5Context gio/glocalfileinfo.c ; then
    quilt import -P revert-glib-4067.patch /src/revert-glib-4067.patch
fi

quilt push -a --fuzz=10
quilt refresh

if grep -qi ubuntu /etc/os-release ; then
    echo "override_dh_builddeb:" >> debian/rules
    echo "	dh_builddeb -- -Zgzip" >> debian/rules
fi

sed -i 's/handle_test_failure := exit $$?/handle_test_failure := true/' ./debian/rules # xxx
if test -f ./debian/control.in ; then
    cfile="./debian/control.in"
elif test -f ./debian/control ; then
    cfile="./debian/control"
else
    echo "Confusion in her eyes that says it all, She's lost control"
    exit 1
fi

sed -i '0,/^Recommends/{s/^Recommends: /Recommends: lomiri-thumbnailer-service | tumbler, /}' "$cfile"

NAME="repo.lol" EMAIL="pkgs@repo.lol" \
    faketime -f @"$(date '+%Y-%m-%d %H:%M:%S' -d@$(( $(date +%s -d"$(grep "^ -- " debian/changelog|head -n1 |cut -d'>' -f2)") +43200 ))) x0.00001" \
    dch --nmu "apply tumbler patch"
sed -i s/UNRELEASED/$RELEASE/ ./debian/changelog

dpkg-buildpackage --compression=gzip
mkdir -p /output/$RELEASE
mv /work/$RELEASE/*deb /output/$RELEASE
