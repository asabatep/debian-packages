all: bullseye bookworm trixie sid installpub

bullseye:
	DISTRO=debian RELEASE=bullseye make build

bookworm:
	DISTRO=debian RELEASE=bookworm make build

trixie:
	DISTRO=debian RELEASE=trixie make build

sid:
	DISTRO=debian RELEASE=sid make build

noble:
	DISTRO=ubuntu RELEASE=noble make build

installpub:
	set -eux && \
	ssh repo-public mkdir -p ~/docker/wwwpub/freight/inbox/${RELEASE} && \
	scp output/${RELEASE}/*deb repo-public:~/docker/wwwpub/freight/inbox/${RELEASE} && \
	ssh repo-public docker exec -t www-freight "/usr/local/bin/ship-it.sh ${RELEASE}"

build:
	mkdir -p output src work
	docker run --rm \
		-e TZ=Etc/UTC \
		-v $$(pwd)/debian:/contrib/debian \
		-v $$(pwd)/src:/src \
		-v $$(pwd)/output:/output \
		-v $$(pwd)/build.sh:/build.sh \
		-v $$(pwd)/work:/work \
		docker.io/${DISTRO}:${RELEASE} /bin/bash -c "DISTRO=${DISTRO} RELEASE=${RELEASE} VER=${VER} /build.sh"
