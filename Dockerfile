FROM debian:stable-slim as builder

ARG WANT_CLAMAV_VERSION=0.100.0

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        wget \
        make \
        gcc \
        libc-dev \
        linux-headers-$(uname -r) \
        libssl-dev \
        libzip-dev \
        libxml2-dev \
        libcurl4-nss-dev \
        libpcre2-dev \
        libjson-c-dev

WORKDIR /opt/clamav-source

RUN wget "https://www.clamav.net/downloads/production/clamav-${WANT_CLAMAV_VERSION}.tar.gz" && \
    tar xf "clamav-${WANT_CLAMAV_VERSION}.tar.gz" && \
    cd "clamav-${WANT_CLAMAV_VERSION}" && \
    ./configure --disable-clamsubmit && \
    make && \
    make install

FROM debian:stable-slim

RUN apt update && \
    apt upgrade -y && \
    apt install -y libxml2 libzip4 libcurl3-nss libpcre2-posix0 libjson-c3 openssl wget && \
    apt autoremove -y
COPY --from=builder /usr/local/lib/*clam* /usr/local/lib/
COPY --from=builder /usr/local/bin/*clam* /usr/local/bin/
COPY --from=builder /usr/local/include/clamav.h /usr/local/include/
COPY --from=builder /usr/local/etc/*clam* /usr/local/etc/
WORKDIR /opt/clamav-test
RUN ldconfig && \
    clamscan --version && \
    wget http://database.clamav.net/bytecode.cvd && \
    echo -n 'X5O!P%@AP[4\PZX54(P^)7CC)7}$' > eicar-test && \
    echo -n 'EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' >> eicar-test && \
    clamscan --database=bytecode.cvd eicar-test ; if [ $? -eq 1 ]; then echo "CHECK OK"; else echo "FAIL" && exit 1; fi && \
    cd / && rm -r /opt/clamav-test
