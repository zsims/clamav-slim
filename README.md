# clamav-alpine
[![Build status](https://badge.buildkite.com/017760520f5cc748d389f0f5e453df600b8abe5ae788fe7acd.svg)](https://buildkite.com/icebergdefender/clamav-alpine)
[![Docker Image Status](https://images.microbadger.com/badges/image/icebergdefender/clamav-alpine.svg)](https://microbadger.com/images/icebergdefender/clamav-alpine)

Alpine Docker Image containing libclamav and friends.

This is a [multi-stage docker build](https://docs.docker.com/develop/develop-images/multistage-build/) that builds ClamAV from source, and installs it into a fresh image.

This image is intended to be used by components that integrate with libclamav (or want clamscan) and as such
 1. **Does not** contain any virus definitions (fetch with freshclam, or download from https://www.clamav.net/downloads
 2. **Does not** have any daemons setup (freshclamd, clamdscan, etc)

Note: clamd and clamdscan are excluded as they rely on FTS which [musl-libc](https://wiki.musl-libc.org/faq.html#Q:-Why-is-%3Ccode%3Efts.h%3C/code%3E-not-included?) does not support as it's broken.

# Example
Build with [an available source version of ClamAV](https://www.clamav.net/downloads):
```
docker build --build-arg=WANT_CLAMAV_VERSION="0.100.0" .
```

Or run
```
docker run --rm -it icebergdefender/clamav-alpine clamscan --version
```

# Thanks

CI/CD charitably provided by [Buildkite.com](https://buildkite.com)
