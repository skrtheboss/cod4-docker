FROM debian:buster-slim AS builder

# NOTE: not using version tag, since this commit has a fix which reduces CPU usage significantly
ARG COD4X_VERSION=14d0a7cc5233a09bfd765fba2b50b1102d3dfbdc

RUN dpkg --add-architecture i386 && \
    apt-get -qq update && \
    apt-get -qq install nasm:i386 build-essential gcc-multilib g++-multilib wget

WORKDIR /cod4

RUN wget https://github.com/callofduty4x/CoD4x_Server/archive/${COD4X_VERSION}.tar.gz && \
    tar -xzf ${COD4X_VERSION}.tar.gz --strip-components=1 && \
    rm ${COD4X_VERSION}.tar.gz && \
	make

FROM bitnami/minideb:buster

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

LABEL org.label-schema.schema-version="1.0.0" \
    maintainer="denisfrenademetz97@gmail.com" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/skrtheboss/cod4-docker" \
    org.label-schema.url="https://github.com/skrtheboss/cod4-docker" \
    org.label-schema.vcs-description="Call of duty 4X Modern Warfare dedicated server" \
    org.label-schema.vcs-usage="https://github.com/skrtheboss/cod4-docker/blob/master/README.md#setup" \
    org.label-schema.docker.cmd="See readme of Github page" \
    org.label-schema.version=$BUILD_VERSION \
    image-size="180MB" \
    ram-usage="80MB to 250MB" \
    cpu-usage="Low"

EXPOSE 28960/udp

RUN useradd user
ADD cod4 /home/user/cod4
RUN chown -R user:user /home/user

WORKDIR /home/user/cod4

COPY --chown=1000 --from=builder /cod4/bin/cod4x18_dedrun .

RUN apt-get -qq update  && \
    # Needed for cod4 to start
    install_packages libc6-i386 lib32stdc++6

RUN chown -R user /home/user && \
    chmod -R 700 /home/user && \
    chmod 500 entrypoint.sh cod4x18_dedrun

ENTRYPOINT [ "/home/user/cod4/entrypoint.sh" ]

CMD +set dedicated 2+set sv_maxclients "24"+exec server.cfg+map_rotate

USER user
