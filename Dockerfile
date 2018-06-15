FROM alpine:3.7 as builder

ARG WANT_CLAMAV_VERSION

RUN apk add --no-cache \
        alpine-sdk \
        linux-headers \
        openssl-dev \
        zlib-dev \
        unrar \
        libxml2-dev \
        curl-dev \
        pcre-dev \
        json-c-dev &&\
        adduser -G abuild -g "Alpine Package Builder" -s /bin/sh -D builder &&\
        echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /usr/src/clamav
RUN chown builder /usr/src/clamav 
USER builder

RUN wget "https://www.clamav.net/downloads/production/clamav-${WANT_CLAMAV_VERSION}.tar.gz" &&\
    tar xf "clamav-${WANT_CLAMAV_VERSION}.tar.gz" &&\
    cd "clamav-${WANT_CLAMAV_VERSION}" &&\
    # clamd and clamdscan depend on fts, which isn't supported in musl libc as it's broken: https://wiki.musl-libc.org/faq.html#Q:-Why-is-%3Ccode%3Efts.h%3C/code%3E-not-included?
    # Additionally, --enable-llvm isn't provided as it's missing from https://pkgs.alpinelinux.org/packages?name=llvm-dev&branch=edge
    ./configure --disable-clamsubmit &&\
    sed -i 's/^\(SUBDIRS = .*\) clamd clamdscan \(.*\)$/\1 \2/' Makefile &&\
    make &&\
    sudo make install


FROM alpine:3.7
RUN apk --no-cache add libxml2 zlib libcurl pcre json-c openssl
COPY --from=builder /usr/local/lib/*clam* /usr/local/lib/
COPY --from=builder /usr/local/bin/*clam* /usr/local/bin/
COPY --from=builder /usr/local/include/clamav.h /usr/local/include/
COPY --from=builder /usr/local/etc/*clam* /usr/local/etc/
WORKDIR /opt/clamav-test
RUN clamscan --version &&\
    wget http://database.clamav.net/bytecode.cvd &&\
    echo -n 'X5O!P%@AP[4\PZX54(P^)7CC)7}$' > eicar-test &&\
    echo -n 'EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' >> eicar-test &&\
    clamscan --database=bytecode.cvd eicar-test ; if [[ $? -eq 1 ]]; then echo "CHECK OK"; else echo "FAIL" && exit 1; fi &&\
    cd / && rm -r /opt/clamav-test
