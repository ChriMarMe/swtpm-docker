# The container is messy as hell.
# I just started working with it, so i try to get along somehow. 
# Need to figure out how to improve this. 
# docker build -t swtpm-ubuntu-18.04 -f Dockerfile .
# docker run -dit swtpm-ubuntu-18.04:latest
FROM 	ubuntu:18.04

ENV	DEBIAN_FRONTEND noninteractive 
ENV 	TPM_PATH=/dev/tpm0

RUN 	apt-get -y update && \
	apt-get -y install apt-transport-https git automake libtool libssl-dev make dpkg-dev dh-exec gawk \
	libfuse-dev libglib2.0-dev libgmp-dev expect libtasn1-dev socat tpm-tools python3-twisted gnutls-dev gnutls-bin \
	net-tools libseccomp-dev trousers && \
	git clone https://github.com/stefanberger/libtpms.git && \
	git clone https://github.com/stefanberger/swtpm.git
WORKDIR /libtpms
RUN	./autogen.sh --with-openssl && \
	make dist && \
	dpkg-buildpackage -us -uc -j$(nproc) && \
	dpkg -i ../libtpms*.deb && \
	apt-get install -f
WORKDIR ../swtpm
RUN	./autogen.sh --with-openssl --prefix=/usr && \
 	make -j$(nproc) && \
	make install && \
 	mkdir /tmp/tpm0 && \
 	chown -R tss:root /tmp/tpm0 && \
 	swtpm_setup --display --tpm-state /tmp/tpm0 --createek --owner-well-known --srk-well-known --take-ownership && \
	swtpm cuse -n tpm0
