FROM innovanon/xorg-base:latest as builder-01
COPY --from=innovanon/util-macros /tmp/util-macros.txz /tmp/
RUN cat   /tmp/*.txz  \
  | tar Jxf - -i -C / \
 && rm -v /tmp/*.txz  \
 && ldconfig

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
 && tar acf        ../xorgproto.txz .                                                       \
 && cd ..                                                                                   \
 && rm -rf       /tmp/xorgproto

