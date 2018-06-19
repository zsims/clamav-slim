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

WORKDIR /usr/local/src/clamav

RUN wget "https://www.clamav.net/downloads/production/clamav-${WANT_CLAMAV_VERSION}.tar.gz" && \
    tar xf "clamav-${WANT_CLAMAV_VERSION}.tar.gz" && \
    cd "clamav-${WANT_CLAMAV_VERSION}" && \
    ./configure --disable-clamsubmit && \
    make && \
    make install

FROM debian:stable-slim

RUN apt update && \
    apt upgrade -y && \
    apt install -y libxml2 libzip4 libcurl3-nss libpcre2-posix0 libjson-c3 openssl curl && \
    apt autoremove -y
COPY --from=builder /usr/local/lib/*clam* /usr/local/lib/
COPY --from=builder /usr/local/bin/*clam* /usr/local/bin/
COPY --from=builder /usr/local/include/clamav.h /usr/local/include/
COPY --from=builder /usr/local/etc/*clam* /usr/local/etc/
RUN sed -i 's/^Example$//' /usr/local/etc/freshclam.conf.sample && \
    mv /usr/local/etc/freshclam.conf.sample /usr/local/etc/freshclam.conf && \
    groupadd clamav && \
    useradd -g clamav -s /bin/false -c "Clam Antivirus" clamav && \
    mkdir /usr/local/share/clamav && \
    chown clamav:clamav /usr/local/share/clamav && \
    echo "Test" && \
    ldconfig && \
    clamscan --version && \
    curl http://database.clamav.net/bytecode.cvd > /usr/local/share/clamav/bytecode.cvd && \
    curl https://www.eicar.org/download/eicar.com.txt | clamscan - ; if [ $? -eq 1 ]; then echo "CHECK OK"; else echo "FAIL" && exit 1; fi && \
    rm -f /usr/local/share/clamav/bytecode.cvd
