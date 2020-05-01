# DESCRIPTION:	  MIPS cross toolchain on wheezy to build packages for unifi OS
# REF:            https://wiki.debian.org/MultiarchCrossToolchainBuild#in_wheezy
FROM debian:wheezy AS source

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/local/src

RUN echo 'deb http://archive.debian.org/debian wheezy main contrib\n\
deb-src http://archive.debian.org/debian wheezy main contrib' > /etc/apt/sources.list \
	  && apt-get update \
    && apt-get install --force-yes -y --no-install-recommends \
		    ca-certificates \
				perl-base=5.14.2-21+deb7u3 \
				libc-dev-bin \
				linux-libc-dev \
				libc-bin=2.13-38+deb7u10 \
				libc6=2.13-38+deb7u10 \
				libc6-dev \
    && apt-get -y build-dep --no-install-recommends binutils \
		&& apt-get source binutils \
		&& cd binutils-2.* \
		&& DEB_TARGET_ARCH=mips TARGET=mips dpkg-buildpackage -b \
		&& cd .. \
		&& dpkg -i binutils-mips*.deb \
    && apt-get install --force-yes -y --no-install-recommends \
        binutils-multiarch \
				xapt \
    && xapt -a mips -m libc6-dev \
		&& apt-get -y build-dep --no-install-recommends gcc-4.7 \
		&& apt-get source gcc-4.7 \
		&& cd gcc-4.7-4.7.* \
    && DEB_TARGET_ARCH=mips DEB_CROSS_NO_BIARCH=yes with_deps_on_target_arch_pkgs=yes dpkg-buildpackage -b


FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/local/src

COPY --from=source /usr/local/src/*.deb ./

RUN echo 'deb http://archive.debian.org/debian wheezy main contrib\n\
deb-src http://archive.debian.org/debian wheezy main contrib' > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --force-yes -y --no-install-recommends \
        ca-certificates \
        perl-base=5.14.2-21+deb7u3 \
        libc-dev-bin \
        linux-libc-dev \
        libc-bin=2.13-38+deb7u10 \
        libc6=2.13-38+deb7u10 \
        libc6-dev \
				binutils-multiarch \
        xapt \
				wget \
		&& apt-get -y build-dep --no-install-recommends gcc-4.7 \
		&& xapt -a mips -m libc6-dev \
		&& dpkg -i *.deb \
		&& ln -s /usr/bin/mips-linux-gnu-cpp-4.7 /usr/bin/mips-linux-gnu-cpp \
		&& ln -s /usr/bin/mips-linux-gnu-gcc-ar-4.7 /usr/bin/mips-linux-gnu-gcc-ar \
		&& ln -s /usr/bin/mips-linux-gnu-gcc-ranlib-4.7 /usr/bin/mips-linux-gnu-gcc-ranlib \
		&& ln -s /usr/bin/mips-linux-gnu-g++-4.7 /usr/bin/mips-linux-gnu-g++ \
		&& ln -s /usr/bin/mips-linux-gnu-gccgo-4.7 /usr/bin/mips-linux-gnu-gccgo \
		&& ln -s /usr/bin/mips-linux-gnu-gcov-4.7 /usr/bin/mips-linux-gnu-gcov \
		&& ln -s /usr/bin/mips-linux-gnu-gcc-4.7 /usr/bin/mips-linux-gnu-gcc \
		&& ln -s /usr/bin/mips-linux-gnu-gcc-nm-4.7 /usr/bin/mips-linux-gnu-gcc-nm \
		&& ln -s /usr/bin/mips-linux-gnu-gfortran-4.7 /usr/bin/mips-linux-gnu-gfortran \
	  && rm -rf /var/lib/apt/lists/*

