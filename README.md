# debian-packages

The sources and documentation for the Debian packages available at https://repo.lol/debian

## available packages

### gtk3 with the thumbnail file chooser patch and glib2 with thumbnail generator patch
This is Debian and Ubuntu gtk3 with [dudemanguy's filechooser icon view patch](https://gist.github.com/Dudemanguy/d199759b46a79782cc1b301649dec8a5), that adds an icon view with thumbnails, and libglib2 with the [glib thumbnailer patch](https://gist.github.com/Dudemanguy/d199759b46a79782cc1b301649dec8a5), that will generate the thumbnails themselves with tumbler.

### debian's dpkg with zstd support
This is debian's dpkg, with support for zstd compression added [by backporting it from Ubuntu](https://patches.ubuntu.com/d/dpkg/dpkg_1.21.9ubuntu1.patch).

This makes it possible to deal with Ubuntu packages in Debian systems, as Ubuntu switched to ztsd compression, such as when building Ubuntu debootstraps on Debian, managing repos, importing packages and similar operations.

Built for Bullseye (dpkg 1.20).

### python3-commandnotfound
Debian build of Ubuntu's python3-commandnotfound (which mysteriously disappeared on the former). Built for Debian Bullseye, Bookworm, Trixie, and Sid.

This adds apt support for [thefuck](https://github.com/nvbn/thefuck) on Debian.

### dnscrypt-proxy
Backport for bookworm only of trixie's dnscrypt-proxy after [it was left on the former](https://github.com/DNSCrypt/dnscrypt-proxy/discussions/2410).

### globalprotect-openconnect
Debian build of [yuezk's globalprotect-openconnect VPN client](https://github.com/yuezk/GlobalProtect-openconnect)

### hadolint
[Hadolint](https://github.com/hadolint/hadolint), a linter for Dockerfiles

## using this repo

Download the signing key with:
```wget -O /usr/share/keyrings/repo.lol.gpg https://repo.lol/debian/keyring.gpg```

Create a file */etc/apt/sources.list.d/repo.lol.list* with the following contents:
```
deb [signed-by=/usr/share/keyrings/repo.lol.gpg] http://repo.lol/debian RELEASE main
```

RELEASE must be your distro release: bullseye, bookworm, trixie, sid, jammy, lunar.

Update your package lists and packages (```apt update ; apt upgrade```). Your dpkg, glib and gtk install will be replaced with the one in this repo, and tumbler will be pulled as a dependency if not installed.

### selective installing

Maybe you only want dpkg from this repo and keep the stock glib and gtk (or viceversa). In this case, an apt preferences file must be created to keep apt from installing the versions from this repo.

Determine the packages to keep installing from Debian:

* for dpkg: ```apt-cache showsrc dpkg | grep " deb " | awk '{print $1}'```
* for glib and gtk: ```apt-cache showsrc glib2.0 gtk+3.0 | grep " deb " | awk '{print $1}'```

Create a file */etc/apt/preferences.d/10-repo-lol* with the following content:
```
Package: PACKAGES-TO-KEEP-INSTALLING-FROM-DEBIAN
Pin: origin repo.lol
Pin-Priority: -1
```

You may also use the one-liners found at the bottom of this file.

## Building

You can easily build your own version of the patched packages by cloning this repo and running ```make``` in the respective directory. The resulting files will be in the ```output/$RELEASE``` directory.

Docker (or podman-docker) and make are the only needed dependencies needed on the host, as the build will take place on an isolated container and everything else will be handled automatically.

## Convenient one-liners
```
# Add the repo
echo deb [signed-by=/usr/share/keyrings/repo.lol.gpg] http://repo.lol/debian $(lsb_release -cs) main | sudo tee /etc/apt/sources.list.d/repo.lol.list && sudo wget -O /usr/share/keyrings/repo.lol.gpg https://repo.lol/debian/keyring.gpg
```

```
# After adding the repo, keep dpkg from debian (if you want glib and gtk but keep stock dpkg)
echo -ne "Package: $(apt-cache showsrc dpkg|grep " deb "|awk '{print $1}' | xargs)\nPin: origin repo.lol\nPin-Priority: -1\n" | sudo tee /etc/apt/preferences.d/10-repo-lol
```

```
# After adding the repo, keep glib and gtk from debian (if you want zstd dpkg but keep stock glib and gtk)
echo -ne "Package: $(apt-cache showsrc glib2.0 gtk+3.0|grep " deb "|awk '{print $1}' | xargs)\nPin: origin repo.lol\nPin-Priority: -1\n" | sudo tee /etc/apt/preferences.d/10-repo-lol
```

## retired packages

### dpkg-zstd

dpkg-zstd packages for bookworm have been retired as support has been added upstream.

### ubuntu kinetic packages

retired due to distro eol.
