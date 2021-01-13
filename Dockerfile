FROM innovanon/xorg-base:latest as builder-01
USER root
COPY --from=innovanon/util-macros /tmp/util-macros.txz /tmp/
RUN extract.sh

# TODO
RUN apt update && apt full-upgrade && apt install meson

ARG LFS=/mnt/lfs
WORKDIR $LFS/sources
USER lfs
RUN sleep 31                                                                                \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/proto/xorgproto.git \
 && cd                                                                        xorgproto     \
 && mkdir -v build                                                                          \
 && cd       build                                                                          \
 && meson --prefix=$XORG_PREFIX -Dlegacy=true ..                                            \
 && ninja                                                                                   \
 && DESTDIR=/tmp/xorgproto ninja install                                                    \
 && cd ../..                                                                                \
 && rm -rf                                                                    xorgproto     \
 && cd           /tmp/xorgproto                                                             \
 && strip.sh .                                                                              \
 && tar  pacf        ../xorgproto.txz .                                                       \
 && cd ..                                                                                   \
 && rm -rf       /tmp/xorgproto

FROM scratch as final
COPY --from=builder-01 /tmp/xorgproto.txz /tmp/

