PROJECT=erlang
VERSION=21.2.7
SAFE_VERSION=21.2.7
PROJECT_NAME=${PROJECT}
PROJECT_VERSION=${VERSION}
DOWNLOAD_SRC=https://github.com/erlang/otp/archive/OTP-${VERSION}.tar.gz
LOCAL_SRC_TAR=src.tar.gz2
LOCAL_SRC=otp-OTP-${VERSION}

USERNAME=erlang
GROUPNAME=erlang

export DESTDIR=${HOME}/build/
PREFIX="/opt/erlang"

PKG_BUILD_DIR="${PREFIX}"
export CPPFLAGS = -D_XOPEN_SOURCE=600 -D__EXTENSIONS__

CONFIGURE_OPTS="--enable-smp-support --enable-dtrace --enable-threads --with-ssl=/usr --enable-dynamic-ssl-lib --enable-m64-build --disable-hipe --prefix=${PREFIX}"


clone:
	curl -fvL ${DOWNLOAD_SRC} -o ${LOCAL_SRC_TAR}
	tar -xvf ${LOCAL_SRC_TAR}
	ls

build:
	@ echo 'Print env before building'
	@ bash -c 'env'
	./fix.sh
	cd ${LOCAL_SRC}; ./otp_build autoconf
	cd ${LOCAL_SRC}; export ERL_TOP=`pwd`
	cd ${LOCAL_SRC}; ./configure "${CONFIGURE_OPTS}"
	cd ${LOCAL_SRC}; make -j 8
	cd ${LOCAL_SRC}; make install

package:
	@echo do packagey things!
	mkdir -p ${IPS_BUILD_DIR}/opt/ ${IPS_TMP_DIR}
	cp -r ${DESTDIR}/* ${IPS_BUILD_DIR}
	chmod +x ${IPS_BUILD_DIR}/opt/erlang/lib/erlang/bin/*

publish: ips-package
ifndef PKGSRVR
	echo "Need to define PKGSRVR, something like http://localhost:10000"
	exit 1
endif
	pkgsend publish -s ${PKGSRVR} -d ${IPS_BUILD_DIR} ${IPS_TMP_DIR}/pkg.pm5.final
	pkgrepo refresh -s ${PKGSRVR}

include ips.mk
