# clamav-alpine
Alpine Docker Image containing libclamav and friends.

[![Build status](https://badge.buildkite.com/017760520f5cc748d389f0f5e453df600b8abe5ae788fe7acd.svg)](https://buildkite.com/icebergdefender/clamav-alpine)

This is a [multi-stage docker build](https://docs.docker.com/develop/develop-images/multistage-build/) that builds clamav.

Note:
 - clamd and clamdscan are excluded as they rely on FTS which [musl-libc](https://wiki.musl-libc.org/faq.html#Q:-Why-is-%3Ccode%3Efts.h%3C/code%3E-not-included?) does not support as it's broken.

# Thanks

CI/CD charitably provided by [Buildkite.com](https://buildkite.com)