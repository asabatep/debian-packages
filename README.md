# debian-packages

The sources and documentation for the Debian packages available at https://repo.lol/debian

## gtk3 with the filechooser patch and glib2 with tumbler patch
This is Debian and Ubuntu gtk3 with [dudemanguy's filechooser icon view patch](https://gist.github.com/Dudemanguy/d199759b46a79782cc1b301649dec8a5), that adds an icon view with thumbnails, and libglib2 with the [glib thumbnailer patch](https://gist.github.com/Dudemanguy/d199759b46a79782cc1b301649dec8a5), that will generate the thumbnails themselves with tumbler.

This package is built for Debian Bullseye, Bookworm and Sid, and for Ubuntu Jammy and Kinetic.

### Installing

You can use a prebuilt package with

*/etc/apt/preferences.d/10-gtk-filechooser-patch*
```
Package: gir1.2-gtk-3.0 gtk-3-examples gtk-3-examples-dbgsym gtk-update-icon-cache gtk-update-icon-cache-dbgsym libgail-3-0 libgail-3-0-dbgsym libgail-3-dev libgail-3-doc libglib2.0-0 libglib2.0-0-dbgsym libglib2.0-bin libglib2.0-bin-dbgsym libglib2.0-data libglib2.0-dev libglib2.0-dev-bin libglib2.0-dev-bin-dbgsym libglib2.0-doc libglib2.0-tests libglib2.0-tests-dbgsym libgtk-3-0 libgtk-3-0-dbgsym libgtk-3-bin libgtk-3-bin-dbgsym libgtk-3-common libgtk-3-dev libgtk-3-doc
Pin: origin repo.lol
Pin-Priority: 800
```

*/etc/apt/sources.list.d/repo.lol.list*
```
deb [signed-by=/usr/share/keyrings/repo.lol.gpg] http://repo.lol/debian RELEASE main
```
Be sure to replace RELEASE with your distro release (bullseye, sid, jammy, kinetic)

Download the key with:
```
wget -O /usr/share/keyrings/repo.lol.gpg https://repo.lol/debian/keyring.gpg
```

Run ```apt-get update && apt-get upgrade```. The patched packages should replace the stock ones.

## python3-commandnotfound
Debian build of Ubuntu's python3-commandnotfound (which mysteriously disappeared on the former). Built for Debian Bullseye, Bookworm, and Sid.

This adds apt support for [thefuck](https://github.com/nvbn/thefuck) on Debian.

### Installing
Add repo and key (see previous instructions, don't create a preferences file for this one) and run ```apt install command-not-found python3-commandnotfound```.

## globalprotect-openconnect
Debian build of [yuezk's globalprotect-openconnect VPN client](https://github.com/yuezk/GlobalProtect-openconnect)

### Installing
Add repo and key (see previous instructions, don't create a preferences file for this one) and run ```apt install globalprotect-openconnect```.

## hadolint
[Hadolint](https://github.com/hadolint/hadolint), a linter for Dockerfiles

### Installing
Add repo and key (see previous instructions, don't create a preferences file for this one) and run ```apt install hadolint```.

## Building

You can easily build your own version of the patched packages by cloning this repo and running ```make``` in the respective directory. The resulting files will be in the ```output/$RELEASE``` directory.

Docker (or podman-docker) and make are the only needed dependencies needed on the host, as the build will take place on an isolated container and everything else will be handled automatically.

## Convenient one-liners
```
# Add the repo
echo deb [signed-by=/usr/share/keyrings/repo.lol.gpg] http://repo.lol/debian $(lsb_release -cs) main | sudo tee /etc/apt/sources.list.d/repo.lol.list && sudo wget -O /usr/share/keyrings/repo.lol.gpg https://repo.lol/debian/keyring.gpg
```

```
# Generate the preferences file for the GTK patch
echo -ne "Package: $(apt-cache showsrc glib2.0 gtk+3.0|grep " deb "|awk '{print $1}' | xargs)\nPin: origin repo.lol\nPin-Priority: 800\n" | sudo tee /etc/apt/preferences.d/10-gtk-filechooser-patch
```
