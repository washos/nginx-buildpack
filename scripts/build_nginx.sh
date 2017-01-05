#!/bin/bash
# Build NGINX and modules on Heroku.
# This program is designed to run in a web dyno provided by Heroku.
# We would like to build an NGINX binary for the buildpack on the
# exact machine in which the binary will run.
# Our motivation for running in a web dyno is that we need a way to
# download the binary once it is built so we can vendor it in the buildpack.
#
# Once the dyno has is 'up' you can open your browser and navigate
# this dyno's directory structure to download the nginx binary.

NGINX_VERSION=${NGINX_VERSION-1.11.8}
PCRE_VERSION=${PCRE_VERSION-8.39}
ZLIB_VERSION=${ZLIB_VERSION-1.2.10}
OPENSSL_VERSION=${OPENSSL_VERSION-1.0.2j}

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
zlib_tarball_url=http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
openssl_tarball_url=http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd ${temp_dir}
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
curl -L ${nginx_tarball_url} | tar -xz

echo "Downloading $pcre_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -L ${pcre_tarball_url} | tar -xz )

echo "Downloading $zlib_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -L ${zlib_tarball_url} | tar -xz )

echo "Downloading $openssl_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -L ${openssl_tarball_url} | tar -xz )

(
	cd nginx-${NGINX_VERSION}
	./configure \
		--prefix=/tmp/nginx \
		--with-pcre=pcre-${PCRE_VERSION} \
        --with-zlib=zlib-${ZLIB_VERSION} \
        --with-http_ssl_module
	make install
)

while true
do
	sleep 1
	echo "."
done
