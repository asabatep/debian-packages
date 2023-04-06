all: build installpub

installpub:
	set -eux && \
	for RELEASE in bullseye bookworm sid jammy kinetic lunar ; do \
		ssh repo-public mkdir -p ~/docker/wwwpub/freight/inbox/$$RELEASE && \
		scp output/*deb repo-public:~/docker/wwwpub/freight/inbox/$$RELEASE && \
		ssh repo-public docker exec -t www-freight "/usr/local/bin/ship-it.sh $$RELEASE" ; \
	done

build:
	mkdir -p output work
	docker run --rm \
		-e TZ=Etc/UTC \
		-v $$(pwd)/debian:/contrib/debian \
		-v $$(pwd)/output:/output \
		-v $$(pwd)/build.sh:/build.sh \
		-v $$(pwd)/work:/work \
		docker.io/debian:bookworm /bin/bash -c "VER=${VER} /build.sh"
