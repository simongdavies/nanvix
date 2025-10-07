FROM scratch

ARG NANVIX_VERSION
ARG MINIJAIL_PATH
ARG NANVIXBIN_PATH

LABEL org.opencontainers.image.runtime.name="hl-nanvix"
LABEL org.opencontainers.image.runtime.requirement="mandatory"
LABEL org.opencontainers.image.architecture="amd64"
LABEL org.opencontainers.image.os="nanvix"
LABEL org.opencontainers.image.platform="nanvix/amd64"
LABEL org.opencontainers.image.authors="The Nanvix Project"
LABEL org.opencontainers.image.source="https://github.com/nanvix/nanvix"
LABEL org.opencontainers.image.version="${NANVIX_VERSION}"

COPY ${MINIJAIL_PATH}/minijail0 /minijail/minijail0
COPY ${MINIJAIL_PATH}/minijail0.sh /minijail/minijail0.sh
COPY ${MINIJAIL_PATH}/libminijailpreload.so /minijail/libminijailpreload.so
COPY ${NANVIXBIN_PATH}/microvm.elf /nanvixbin/microvm.elf
COPY ${NANVIXBIN_PATH}/kernel.elf /nanvixbin/kernel.elf
COPY ${NANVIXBIN_PATH}/nanvixd.elf /nanvixbin/nanvixd.elf
COPY ${NANVIXBIN_PATH}/linuxd.elf /nanvixbin/linuxd.elf

ENV NANVIX_LOG_LEVEL=error
ENV NANVIX_LOG_DIR=./logs