# clamav-alpine
Alpine Docker Image containing libclamav and friends.

This is a [multi-stage docker build](https://docs.docker.com/develop/develop-images/multistage-build/) that builds clamav.

Note:
 - clamd and clamdscan are excluded as they rely on FTS which [musl-libc](https://wiki.musl-libc.org/faq.html#Q:-Why-is-%3Ccode%3Efts.h%3C/code%3E-not-included?) does not support as it's broken.
