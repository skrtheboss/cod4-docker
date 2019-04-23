ARG DEBIAN_VERSION=stretch-slim
ARG ALPINE_VERSION=3.9

FROM debian:${DEBIAN_VERSION} as builder
ARG COD4X_VERSION=v17.7.2
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y nasm:i386 build-essential gcc-multilib g++-multilib unzip paxctl wget
WORKDIR /cod4
RUN wget https://github.com/callofduty4x/CoD4x_Server/archive/${COD4X_VERSION}.tar.gz && \
    tar -xzf ${COD4X_VERSION}.tar.gz --strip-components=1 && \
    rm ${COD4X_VERSION}.tar.gz && \
    sed -i 's/LINUX_LFLAGS=/LINUX_LFLAGS=-static /' makefile && \
    make

FROM alpine:${ALPINE_VERSION}
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.schema-version="1.0.0-rc1" \
      maintainer="quentin.mcgaw@gmail.com" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/qdm12/cod4-docker" \
      org.label-schema.url="https://github.com/qdm12/cod4-docker" \
      org.label-schema.vcs-description="Call of duty 4X Modern Warfare dedicated server" \
      org.label-schema.vcs-usage="https://github.com/qdm12/cod4-docker/blob/master/README.md#setup" \
      org.label-schema.docker.cmd="docker run -d --name=cod4 -p 28960:28960/udp -v $(pwd)/main:/cod4/main -v $(pwd)/zone:/cod4/zone:ro -v $(pwd)/mods:/cod4/mods -v $(pwd)/usermaps:/cod4/usermaps:ro qmcgaw/cod4 +map mp_shipment" \
      org.label-schema.docker.cmd.devel="docker run -it --rm --name=cod4 -p 28960:28960/udp -v $(pwd)/main:/cod4/main -v $(pwd)/zone:/cod4/zone:ro qmcgaw/cod4 +map mp_shipment" \
      org.label-schema.docker.params="" \
      org.label-schema.version="1.8-17.7" \
      image-size="19.8MB" \
      ram-usage="80MB to 150MB" \
      cpu-usage="Low"
EXPOSE 28960/udp
WORKDIR /home/user/cod4
COPY --chown=1000 --from=builder /cod4/bin/cod4x18_dedrun .
COPY --chown=1000 entrypoint.sh server.cfg vendor/xbase_00.iwd ./
RUN adduser -S user -h /home/user -u 1000 && \
    chown -R user /home/user && \
    chmod -R 700 /home/user && \
    mkdir usermaps mods zone main && \
    chown -R user /home/user/cod4 && \
    chmod -R 700 /home/user/cod4 && \
    chmod 500 entrypoint.sh cod4x18_dedrun && \
    chmod -R 700 main mods
ENTRYPOINT [ "/home/user/cod4/entrypoint.sh" ]
CMD +set dedicated 2+set sv_cheats "1"+set sv_maxclients "64"+exec server.cfg+map_rotate
USER user
